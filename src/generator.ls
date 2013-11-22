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
        "2013"      : <[radost super nadhera]>
        "2014"      : <[ponurost jejda hruza]>

    for party, words of words_party
        words.forEach (word) ->
            shouts.saveApproved word, party, 10 #Math.ceil Math.random! * 30_000
    shouts.setMood \radost \2013 \positive
    shouts.setMood \hruza \2014 \negative
#fillInitialData!

<~ wordCloudDataConnector.loadFirstData!
console.log "Computed"
console.log outputCache.currentOutput.toString!
(err) <~ redisClient.set "currentData" outputCache.currentOutput
console.log "Saved"
redisClient.quit!
console.error err if err
<~ setTimeout _, 2000
process.exit!
# process.exit!
