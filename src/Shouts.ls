require! async
module.exports = class Shouts
    getStoreAll: -> "shouts:_all"
    getStoreParty: -> "shouts:#it"
    getStorePending: -> "shouts:_pending"
    pendingDelimiter: ";"
    (@redisClient, @antispam, @parties) ->

    getAll: (cb) ->
        @getFromStore @getStoreAll!, cb

    getAllByParty: (cb) ->
        (err, termsByParties) <~ async.map @parties, (partyId, cb) ~>
            (err, terms) <~ @get partyId
            return cb err if err
            terms.forEach -> it.party = partyId
            cb null terms
        return cb err if err
        output = [].concat ...termsByParties
        output .= sort (a, b) -> b.score - a.score
        cb null output



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

    getUnapproved: (cb) ->
        (err, allUnapproved) <~ @redisClient.zrangebyscore do
            @getStorePending!
            0
            +Infinity
            \WITHSCORES
        return cb err if err
        list = for let i in [0 til allUnapproved.length by 2]
            record = allUnapproved[i]
            [term, partyId] = record.split @pendingDelimiter
            score = parseInt allUnapproved[i + 1], 10
            {term, partyId, score, record}
        cb null list


    approve: (approvedTerm, cb) ->
        (err, allUnapproved) <~ @getUnapproved
        termUnapproved = allUnapproved.filter -> it.term is approvedTerm
        tasks = []
        termUnapproved.forEach ({term, partyId, score, record}) ~>
            tasks.push ~> @saveApproved term, partyId, score, it
            tasks.push ~> @redisClient.zrem @getStorePending!, record, it
        (err) <~ async.parallel tasks
        return cb err if err
        cb null tasks.length / 2

    ban: (bannedTerm, cb) ->
        tasks = @parties.map (party) ~>
            (cb) ~> @redisClient.zincrby @getStorePending!, -Infinity, "#bannedTerm#{@pendingDelimiter}#party", cb
        (err) <~ async.parallel tasks
        cb err




