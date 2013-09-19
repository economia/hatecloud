module.exports = class AjaxHandler
    (@shouts) ->
    handle: (req, res, currentOutput, currentOutputLength) ->
        switch req.method
        | \GET
            (err, data) <~ @shouts.getAll!
            if err
                res.statusCode = 500
            else
                res.writeHead do
                    *   200
                    *   'Content-Type': 'application/json;charset=UTF-8'
                        'Content-Length': currentOutputLength
                res.write currentOutput
            res.end!
        | \POST
            query = ""
            req.on \data -> query += it
            req.on \end ->
                data = querystring.parse query
                validData = data?["terms[]"]?length > 0
                validData &&= data?party
                terms = data.["terms[]"]
                party = data.party
                validData = typeof! party == \String
                validData = typeof! terms == \Array
                unless  validData
                    res.statusCode = 500
                    res.end!
                else
                    try
                        ip = req.connection.remoteaddress
                        (err, result) <~ @shouts.save ip, ...terms, party
                        switch
                        | err                           => res.statusCode = 500
                        | result == \non-existing-party => res.statusCode = 404
                        | result == \blocked            => res.statusCode = 403
                        | otherwise                     => res.write result
                        res.end!
                    catch
                        console.error "Chyba pri datech: #query"
                        res.statusCode = 500
                        res.end!
            req.resume!
