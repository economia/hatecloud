# Class that watches whether the IP (ip) has voted for party (partyId) in the last
# (timeout) seconds.
module.exports = class Antispam
    (@redisClient, {timeout}:options) ->
        @options = options

    # == check && register
    exec: (ip, partyId, cb) ->
        (err, result) <~ @check ip, partyId
        return cb err if err
        switch result
        | yes
            (err) <~ @register ip, partyId
            return cb err if err
            cb null yes
        | no
            cb null no

    check: (ip, partyId, cb) ->
        key = @getKey ip
        (err, result) <~ @redisClient.sismember key, partyId
        cb err, !result

    register: (ip, partyId, cb) ->
        key = @getKey ip
        (err, result) <~ @redisClient.sadd key, partyId
        @redisClient.expire key, @options.timeout
        cb err

    getKey: (ip) ->
        "antispam:#ip"
