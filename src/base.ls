require! {
    StaticServer : 'node-static'.Server
    http
}

file = new StaticServer "./www"
server = http.createServer (req, res) ->
    url = req.url.split '/'
    switch url[1]
    | "term"
        handleRequest req, res
    | otherwise
        req.on \end ->
            file.serve req, res
        req.resume!
server.listen 80


handleRequest = (req, res) ->
    console.log \term
    console.log req.connection.remoteAddress
