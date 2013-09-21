require! {
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
wordCloud = new WordCloud!
wordCloudDataConnector = new WordCloudDataConnector do
    shouts
    wordCloud
    outputCache
    config

fillInitialData = ->
    console.log 'filling random data'
    words_party =
        top  : <[Kalousek Kníže Spánek Gripeny Šlechta Přeběhlictví Arogance Škrty Elity Korupce ]>
        ods  : <[Nagygate Kmotři Minulost Nedůvěra Zklamání Nejistota Korupce Podnikatelé  Němcová Daně]>
        cssd : <[Nejednostnost Sobotka Levicovost Hašek Socialismus Populismus Plýtvání Daně Komunisté Nemodernost]>
        kscm : <[Minulost Nomenklatura Totalita Komunismus Osmačtyřicátý Osmašedesátý Zastaralost Znárodnění Strach Nedůvěra]>
        ano  : <[KSČ Podnikatel Babiš Peníze Populismus Berlusconizace Nedůvěryhodnost Účelovost Diktátor Program]>
        spoz : <[Zeman Nejednotnost Šlouf Kancléř Účelovost Lukoil Papaláš Populismus Nečitelnost Pochybnost]>
        kdu  : <[Otazníky Konzervatismus Křešťanství Nestálost Osobnosti Nejasnost Čunek Prodejnost Nevýraznost Nemodernost]>
        sz   : <[Levicovost Nečitelnost Osobnosti Marnost Ekologie Program Nezkušenost Zklamání Energetika  Radikalismus]>

    for party, words of words_party
        words.forEach (word) ->
            shouts.saveApproved word, party, 10 #Math.ceil Math.random! * 30_000
# fillInitialData!

<~ wordCloudDataConnector.loadFirstData!
console.log "Computed"
(err) <~ redisClient.set "currentData" outputCache.currentOutput
console.log "Saved"
redisClient.quit!
console.error err if err
<~ setTimeout _, 2000
process.exit!
# process.exit!
