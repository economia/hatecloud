require! {
    child_process.exec
    StaticServer : 'node-static'.Server
    http
    redis
    querystring
    './Shouts'
    './Antispam'
    './config'
    './AjaxHandler'
    './OutputCache'
}
redisClient = redis.createClient config.redis.port, config.redis.address

antispam = new Antispam redisClient, config.antispam
shouts = new Shouts redisClient, antispam, config.shouts.parties
outputCache = new OutputCache redisClient
ajaxHandler = new AjaxHandler shouts, outputCache

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
regenerate = ->
    (err) <~ exec "node #__dirname/generator.js"
    console.error err if err
    outputCache.refresh!

regenerate!
if config.wordCloud.interval
    setInterval regenerate, that
