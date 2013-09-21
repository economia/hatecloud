require! querystring
module.exports = class AjaxHandler
    (@shouts, @outputCache) ->
    handle: (req, res) ->
        switch req.method
        | \GET => @hadleGetCloud ...
        | \POST => @handlePostTerm ...

    hadleGetCloud: (req, res) ->
        res.writeHead do
            *   200
            *   'Content-Type': 'application/json;charset=UTF-8'
                'Content-Length': @outputCache.currentOutputLength
        res.write @outputCache.currentOutput
        res.end!

    handlePostTerm: (req, res) ->
        query = ""
        req.on \data -> query += it
        req.on \end ~>
            data = @extractPostData query
            if data is null
                @endBadly res
            else
                try
                    {terms, party} = data
                    ip = req.connection.remoteAddress
                    (err, result) <~ @shouts.save ip, ...terms, party
                    switch
                    | err                           => res.statusCode = 500
                    | result == \non-existing-party => res.statusCode = 404
                    | result == \blocked            => res.statusCode = 403
                    | otherwise                     => res.write result
                    res.end!
                catch
                    console.error "Chyba pri datech: #query"
                    @endBadly res
        req.resume!

    endBadly: (response) ->
        response.statusCode = 500
        response.end!

    extractPostData: (query) ->
        data = querystring.parse query
        return null unless data?["terms[]"]?length > 0
        return null unless data?party
        terms = data.["terms[]"]
        party = data.party
        return null unless typeof! party == \String
        return null unless typeof! terms == \Array
        {terms, party}
