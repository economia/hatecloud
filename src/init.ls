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
wordCloud = new WordCloud shouts
wordCloudDataConnector = new WordCloudDataConnector do
    shouts
    wordCloud
    outputCache
    config

fillInitialData = ->
    console.log "Flushing DB"
    <~ redisClient.flushdb!
    console.log 'filling random data'
    words_party =
        "ods" :
            \Klaus
            \Topolánek
            \Nečas
            \Janoušek
            \Rittig
            \Němcová
            \Hrdlička
            \Kuba
            \Kubera
            \Nagyová
            \Dlouhý
            \Bém
            \Svoboda
            \Oulický
            \Jurečko


    for party, words of words_party
        words.forEach (word) ->
            shouts.saveApproved word, party, 10 #Math.ceil Math.random! * 30_000
fillInitialData!
<~ setTimeout _, 2000
process.exit!
