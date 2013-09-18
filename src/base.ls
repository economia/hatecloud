require! {
    StaticServer : 'node-static'.Server
    http
    redis
    './Shouts'
    './Antispam'
    './WordCloud'
    './config'
}
redisClient = redis.createClient config.redis.port, config.redis.address

antispam = new Antispam redisClient, config.antispam
shouts = new Shouts redisClient, antispam, config.shouts.parties
wordCloud = new WordCloud!
currentCloudObject = {}
currentOutput = null
currentOutputLength = 0

fileServer = new StaticServer "./www"
server = http.createServer (req, res) ->
    url = req.url.split '/'
    switch url[1]
    | "term"
        handleRequest req, res
    | otherwise
        req.on \end ->
            fileServer.serve req, res
        req.resume!
server.listen 80

handleRequest = (req, res) ->
    if req.method == \GET
        (err, data) <~ shouts.getAll!
        if err
            res.statusCode = 500
        else
            res.writeHead do
                *   200
                *   'Content-Type': 'application/json;charset=UTF-8'
                    'Content-Length': currentOutputLength
            res.write currentOutput
        res.end!
    # if req.connection.remoteAddress in <[ 127.0.0.1 194.228.51.218 ]>

fillRandomData = ->
    console.log 'filling random data'
    words_party =
        top  : <[Kalousek Kníže Spánek Gripeny Šlechta Přeběhlictví Arogance Škrty Elity Korupce ]>
        ods  : <[ Nagygate Kmotři Minulost Nedůvěra Zklamání Nejistota Korupce Podnikatelé  Němcová Daně]>
        cssd : <[Nejdnostnost Sobotka Levicovost Hašek Socialismus Populismus Plýtvání Daně Komunisté Nemodernost]>
        kscm : <[Minulost Nomenklatura Totalita Komunismus Osmačtyřicátý Osmašedesátý Zastaralost Znárodnění Strach Nedůvěra]>
        ano  : <[KSČ Podnikatel Babiš Peníze Populismus Berlusconizace Nedůvěryhodnost Účelovost Diktátor Program]>
        spoz : <[Zeman Nejednotnost Šlouf Kancléř Účelovost Lukoil Papaláš Populismus Nečitelnost Pochybnost]>
        kdu  : <[Otazníky Konzervatismus Křešťanství Nestálost Osobnosti Nejasnost Čunek Prodejnost Nevýraznost Nemodernost]>
        sz   : <[Levicovost Nečitelnost Osobnosti Marnost Ekologie Program Nezkušenost Zklamání Energetika  Radikalismus]>


    for party, words of words_party
        words.forEach (word) ->
            shouts.saveApproved word, party, Math.ceil Math.random! * 30_000

loadFirstData = ->
    (err, terms) <~ shouts.getAllByParty!
    return console.error err if err
    generateGlobalCloud terms
    config.shouts.parties.forEach (party) ->
        generatePartyCloud terms, party
generatingIndex = 0
generatorRoundRobin = ->
    if generatingIndex > config.shouts.parties.length
        generatingIndex := 0
    party = config.shouts.parties[generatingIndex]
    if party
        refreshParty party
    else
        refreshGlobal!
    generatingIndex++

refreshGlobal = ->
    (err, terms) <~ shouts.getAllByParty!
    return console.error err if err
    generateGlobalCloud terms


refreshParty = (party) ->
    (err, terms) <~ shouts.get party
    return console.error err if err
    generatePartyCloud terms, party


generateGlobalCloud = (terms) ->
    wordCloud.generate do
        convertToGlobal terms
        config.wordCloud
        (err, cloud) ->
            return console.error err if err
            updateCurrent cloud

generatePartyCloud = (terms, party) ->
    wordCloud.generate do
        convertToParty terms, party
        config.wordCloud
        (err, cloud) ->
            return console.error err if err
            updateCurrent cloud, party

updateCurrent = (data, party = null) ->
    if party == null then party = 'all'
    console.log "Updating current #party"
    currentCloudObject[party] := data
    currentOutput             := new Buffer JSON.stringify currentCloudObject
    currentOutputLength       := currentOutput.length

convertToGlobal = (terms) ->
    maxScore = Math.max ...terms.map (.score)
    words = terms.map ->
        text : it.term
        size: computeSize maxScore, it.score
        party: it.party

convertToParty = (terms, party) ->
    partyTerms = terms.filter -> it.party == party
    maxScore = Math.max ...partyTerms.map (.score)
    words = partyTerms.map ->
        text : it.term
        size: computeSize maxScore, it.score

computeSize = (maxScore, score) ->
    config.wordCloud.minSize + config.wordCloud.maxSize * score / maxScore




loadFirstData!
# fillRandomData!
setInterval generatorRoundRobin, config.wordCloud.interval
