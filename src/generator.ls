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
    console.log "Flushing DB"
    <~ redisClient.flushdb!
    console.log 'filling random data'
    words_party =
        top      : <[konzervatismus Schwarzenberg pravice]>
        ods      : <[pravice premiérka daně]>
        cssd     : <[zaměstnanost zdravotnictví důchod]>
        kscm     : <[jistoty protest levice]>
        ano      : <[ostuda vztek radost zklamání hnus znechucení hurá vítězství katastrofa naděje hrůza super]>
        spoz     : <[Zeman odborníci Hůlka]>
        kdu      : <[tradice rodina hodnoty]>
        sz       : <[ekologie zodpovědnost Liška]>
        svobodni : <[EU Mach nezávislost]>
        pirati   : <[internet otevřenost referenda]>
        hlvzhuru : <[Bobošíková dekrety Klaus]>
        zmena    : <[Fischerová rovnoprávnost pravda]>
        usvit    : <[Okamura pořádek Bárta]>
        lev      : <[Paroubek přiznání referendum]>

    for party, words of words_party
        words.forEach (word) ->
            shouts.saveApproved word, party, 10 #Math.ceil Math.random! * 30_000
# fillInitialData!

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
