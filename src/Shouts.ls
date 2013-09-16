require! async
module.exports = class Shouts
    getStoreAll: -> "shouts:_all"
    getStoreParty: -> "shouts:#it"
    getStorePending: -> "shouts:_pending"
    pendingDelimiter: ";"
    (@redisClient, @antispam, @parties) ->

    getAll: ->

    get: (partyId) ->

    save: (ip, ...terms, partyId, cb) ->
        existingParty = partyId in @parties
        return cb null \non-existing-party unless existingParty
        (err, allowed) <~ @antispam.exec ip, partyId
        return cb null \blocked unless allowed
        (err, results) <~ async.map do
            terms
            (term, cb) ~> @saveOne term, partyId, cb
        return cb err if err
        result = if \pending in results then \pending else \ok
        cb err, result

    saveOne: (term, partyId, cb) ->
        (err, termApproved) <~ @isApproved term
        return cb err if err
        switch termApproved
        | yes => @saveApproved term, partyId, 1, cb
        | no  => @savePending term, partyId, cb


    saveApproved: (term, partyId, score, cb) ->
        storeAll = @getStoreAll!
        storeParty = @getStoreParty partyId
        (err) <~ async.parallel do
            *   (cb) ~> @redisClient.zincrby storeAll, score, term, cb
                (cb) ~> @redisClient.zincrby storeParty, score, term, cb
        return cb? err if err
        cb? null \ok

    savePending: (term, partyId, cb) ->
        key = "#term#{@pendingDelimiter}#partyId"
        (err) <~ @redisClient.zincrby @getStorePending!, 1, key
        return cb err if err
        cb null \pending


    isApproved: (term, cb) ->
        (err, result) <~ @redisClient.zscore @getStoreAll!, term
        return cb err if err
        switch result
        | null => cb null no
        | _    => cb null yes

    approve: (approvedTerm, cb) ->
        (err, allUnapproved) <~ @redisClient.zrangebyscore do
            @getStorePending!
            0
            +Infinity
            'WITHSCORES'
        return cb err if err
        termsFound = 0
        for i in [0 til allUnapproved.length by 2]
            [term, partyId] = allUnapproved[i].split @pendingDelimiter
            continue if term isnt approvedTerm
            score = parseInt allUnapproved[i + 1], 10
            @saveApproved term, partyId, score
            @redisClient.zrem @getStorePending!, allUnapproved[i]
            ++termsFound

        cb null termsFound
