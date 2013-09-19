require! {
    StaticServer : 'node-static'.Server
    http
    redis
    querystring
    './Shouts'
    './Antispam'
    './WordCloud'
    './config'
    './AjaxHandler'
    './WordCloudDataConnector'
    './OutputCache'
}
redisClient = redis.createClient config.redis.port, config.redis.address

antispam = new Antispam redisClient, config.antispam
shouts = new Shouts redisClient, antispam, config.shouts.parties
outputCache = new OutputCache
ajaxHandler = new AjaxHandler shouts, outputCache
wordCloud = new WordCloud!
wordCloudDataConnector = new WordCloudDataConnector do
    shouts
    wordCloud
    outputCache
    config
fileServer = new StaticServer "./www"

server = http.createServer (req, res) ->
    url = req.url.split '/'
    switch url[1]
    | "term"
        ajaxHandler.handle req, res
    | otherwise
        req.on \end -> fileServer.serve req, res
        req.resume!
server.listen 80

    # if req.connection.remoteAddress in <[ 127.0.0.1 194.228.51.218 ]>

fillInitialData = ->
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
            shouts.saveApproved word, party, 10 #Math.ceil Math.random! * 30_000
# fillInitialData!





wordCloudDataConnector.loadFirstData!
setInterval wordCloudDataConnector~generateNextCloud, config.wordCloud.interval
