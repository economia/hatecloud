module.exports = class OutputCache
    cloudObject: {}
    currentOutput: null
    currentOutputLength: 0
    (@redisClient) ->
    set: (values, party = null) ->
        if party == null then party = 'all'
        console.log "Updating current #party"
        @cloudObject[party] = values
        @setOutput new Buffer JSON.stringify @cloudObject

    setOutput: (buf) ->
        @currentOutput       = buf
        @currentOutputLength = buf.length

    refresh: ->
        (err, data) <~ @redisClient.get "currentData"
        return console.error err if err
        @setOutput new Buffer data
