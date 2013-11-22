require! {
    async
    events.EventEmitter
}
module.exports = class Shouts extends EventEmitter
    getStoreAll: -> "shouts:_all"
    getStoreMoods: -> "shouts:_moods"
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
        standardizedTerm = @standardizeTerm term
        (err, fullTerm) <~ @getFullTerm standardizedTerm
        if fullTerm then term := that
        (err, termApproved) <~ @isApproved term, partyId
        return cb err if err
        switch termApproved
        | yes => @saveApproved term, partyId, 1, cb
        | no  => @savePending term, partyId, cb

    getFullTerm: (standardizedTerm, cb) ->
        (err, term) <~ @redisClient.hget \synonyms standardizedTerm
        cb null term

    saveStandardizedTerm: (term, cb) ->
        standardizedTerm = @standardizeTerm term
        (err) <~ @redisClient.hset \synonyms standardizedTerm, term
        cb? err, standardizedTerm

    standardizeTerm: (term) ->
        term.toLowerCase!

    saveApproved: (term, partyId, score, cb) ->
        storeAll = @getStoreAll!
        storeParty = @getStoreParty partyId
        @saveStandardizedTerm term
        (err) <~ async.parallel do
            *   (cb) ~> @redisClient.zincrby storeAll, score, term, cb
                (cb) ~> @redisClient.zincrby storeParty, score, term, cb
        return cb? err if err
        cb? null \ok

    savePending: (term, partyId, cb) ->
        key = "#term#{@pendingDelimiter}#partyId"
        (err, +newScore) <~ @redisClient.zincrby @getStorePending!, 1, key
        if newScore == 1
            @emit \newUnapproved term, partyId
        return cb err if err
        cb null \pending

    isApproved: (term, partyId, cb) ->
        store = @getStoreParty partyId
        (err, result) <~ @redisClient.zscore store, term
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

    approve: (term, partyId, cb) ->
        @saveStandardizedTerm term
        record = @getRecordString term, partyId
        (err, score) <~ @redisClient.zscore @getStorePending!, record
        return cb err if err
        return cb null 0 if score is null
        (err) <~ async.parallel do
            *   ~> @saveApproved term, partyId, score, it
                ~> @redisClient.zrem @getStorePending!, record, it
        return cb err if err
        cb null 1

    setMood: (term, partyId, mood, cb) ->
        store = @getStoreMoods!
        key = "#{term}#{@pendingDelimiter}#{partyId}"
        (err) <~ @redisClient.hset store, key, mood
        cb? err

    getMood: (term, partyId, cb) ->
        store = @getStoreMoods!
        key = "#{term}#{@pendingDelimiter}#{partyId}"
        (err, mood) <~ @redisClient.hget store, key
        cb err, mood


    ban: (term, partyId, cb) ->
        record = @getRecordString term, partyId
        (err) <~ @redisClient.zincrby @getStorePending!, -Infinity, record
        cb err

    getRecordString: (term, partyId) ->
        "#term#{@pendingDelimiter}#partyId"
