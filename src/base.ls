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
    './AdminHandler'
    './OutputCache'
    io: 'socket.io'
}
redisClient = redis.createClient config.redis.port, config.redis.address

antispam = new Antispam redisClient, config.antispam
shouts = new Shouts redisClient, antispam, config.shouts.parties
outputCache = new OutputCache redisClient
ajaxHandler = new AjaxHandler shouts, outputCache
fileServer = new StaticServer do
    *   "#__dirname/../www"
    *   gzip: yes

server = http.createServer (req, res) ->
    url = req.url.split '/'
    switch
    | url[1] is "term"
        ajaxHandler.handle req, res
    | url[1] is \img and \cloud.png is url[2]?substr 0, 9
        handleImageRequest req, res
    | otherwise
        req.on \end -> fileServer.serve req, res
        req.resume!
server.listen 80
sockets = io.listen server
    ..set 'log level' 2
adminHandler = new AdminHandler sockets, shouts, config.admin

regenerate = ->
    (err) <~ exec "node #__dirname/generator.js"
    console.error err if err
    outputCache.refresh!
    if config.wordCloud.interval
        setTimeout regenerate, that

handleImageRequest = (req, res) ->
    | outputCache.currentImageLength
        res.writeHead do
            *   200
            *   'Content-Type': 'image/png'
                'Content-Length': outputCache.currentImageLength
        res.write outputCache.currentImage
        res.end!
    | otherwise
        res.statusCode = 500
        res.end!

outputCache.refresh!
regenerate!
