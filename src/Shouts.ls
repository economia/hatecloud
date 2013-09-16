require! async
module.exports = class Shouts
    getStoreAll: -> "shouts:_all"
    getStoreParty: -> "shouts:#it"
    getStorePending: -> "shouts:_pending"
    pendingDelimiter: ";"
    (@redisClient, @antispam, @parties) ->

    getAll: (cb) ->
        @getFromStore @getStoreAll!, cb

    get: (partyId, cb) ->
        store = @getStoreParty partyId
        @getFromStore store, cb

    getFromStore: (store, cb) ->
        (err, results) <~ @redisClient.zrevrangebyscore do
            store
            +Infinity
            0
            \WITHSCORES
        return cb err if err
        formatted = for i in [0 til results.length by 2]
            term = results[i]
            score = parseInt results[i + 1], 10
            {term, score}

        cb null formatted

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
            \WITHSCORES
        return cb err if err
        tasks = []
        for let i in [0 til allUnapproved.length by 2]
            [term, partyId] = allUnapproved[i].split @pendingDelimiter
            return if term isnt approvedTerm
            score = parseInt allUnapproved[i + 1], 10
            tasks.push ~> @saveApproved term, partyId, score, it
            tasks.push ~> @redisClient.zrem @getStorePending!, allUnapproved[i], it
        (err) <~ async.parallel tasks
        return cb err if err
        cb null tasks.length / 2


