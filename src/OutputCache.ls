require! {
    fs
    async
}
module.exports = class OutputCache
    cloudObject: {}
    currentOutput: null
    currentOutputLength: 0
    currentImage: null
    currentImageLength: 0
    (@redisClient) ->
    set: (values, party = null) ->
        if party == null then party = 'all'
        console.log "Updating current #party"
        @cloudObject[party] = values
        @setOutput new Buffer JSON.stringify @cloudObject

    setOutput: (buf) ->
        @currentOutput       = buf
        @currentOutputLength = buf.length

    setImage: (buf) ->
        @currentImage       = buf
        @currentImageLength = buf.length

    refresh: ->
        async.parallel [@~refreshOutput, @~refreshImage]

    refreshOutput: (cb) ->
        (err, data) <~ @redisClient.get "currentData"
        return console.error err if err
        @setOutput new Buffer data
        cb!

    refreshImage: (cb) ->
        (err, buf) <~ fs.readFile "#__dirname/../www/img/cloud.png"
        return cb null if err
        @setImage buf
        cb!
