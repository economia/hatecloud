require! {
    expect : "expect.js"
    '../src/Antispam'
    async
    redis
}
redisClient = redis.createClient 6379 '192.168.123.16'
test = it
describe 'Antispam' ->
    antispam = new Antispam redisClient, timeout: 1
    ip = '127.0.0.1'
    checkFromIp = (party, cb) -> antispam.exec ip, party, cb
    before (done) ->
        <~ redisClient.select 1
        <~ redisClient.flushdb!
        done!
    after (done) ->
        <~ redisClient.flushdb!
        done!
    describe 'first vote' ->
        test 'should allow first vote on all parties' (done) ->
            (err, results) <~ async.map <[ods cssd]> checkFromIp
            expect err .to.be null
            expect results.0 .to.be true
            expect results.1 .to.be true
            done!

        test 'should not allow second vote by same IP' (done) ->
            (err, results) <~ async.map <[ods cssd]> checkFromIp
            expect err .to.be null
            expect results.0 .to.be false
            expect results.1 .to.be false
            done!
        test 'other IP should still be allowed to vote' (done) ->
            (err, result) <~ antispam.exec '127.0.0.2' \ods
            expect result .to.be true
            done!
        test 'and the first IP should be allowed to vote for other parties' (done) ->
            (err, result) <~ checkFromIp \top
            expect result .to.be true
            done!

    describe 'timing out' ->
        before (done) ->
            setTimeout done, 1100
        test 'should again allow voting after a time period' (done) ->
            (err, results) <~ async.map <[ods cssd]> checkFromIp
            expect err .to.be null
            expect results.0 .to.be true
            expect results.1 .to.be true
            done!
        test 'and second vote should be again disallowed' (done) ->
            (err, results) <~ async.map <[ods cssd]> checkFromIp
            expect err .to.be null
            expect results.0 .to.be false
            expect results.1 .to.be false
            done!



