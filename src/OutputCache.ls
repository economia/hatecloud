module.exports = class OutputCache
    cloudObject: {}
    currentOutput: null
    currentOutputLength: 0
    set: (values, party = null) ->
        if party == null then party = 'all'
        console.log "Updating current #party"
        @cloudObject[party] = values
        @setOutput new Buffer JSON.stringify @cloudObject

    setOutput: (buf) ->
        @currentOutput       = buf
        @currentOutputLength = buf.length
