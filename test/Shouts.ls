require! {
    expect : "expect.js"
    '../src/Shouts'
    async
    redis
    './config'
}
redisClient = redis.createClient config.redis.port, config.redis.address
test = it
describe 'Shouts' ->
    before (done) ->
        <~ redisClient.select config.redis.db
        <~ redisClient.flushdb!
        done!
    after (done) ->
        <~ redisClient.flushdb!
        done!
    antispamResult = yes
    antispamMock =
        requests: []
        exec: (ip, partyId, cb) ->
            @requests.push {ip, partyId}
            cb null antispamResult
    shouts = new Shouts redisClient, antispamMock, <[ods cssd top]>
    data = [
        <[termA termB termC ods]>
        <[termB ods]>
        <[termA termD cssd]>
        <[termA termE top]>
    ]
    ip = '127.0.0.1'
    describe 'Create and Retrieve: ' ->
        describe 'Create before Approval' ->
            test 'should save a new shout' (done) ->
                (err, results) <~ async.map data, (dato, cb) ->
                    shouts.save ip, ...dato, cb
                expect err .to.be null
                expect results .to.have.length data.length
                results.forEach -> expect it .to.equal \pending
                done!
            test 'should return "non-existing-party" when trying to shout to a non-existing party' (done) ->
                (err, result) <~ shouts.save ip, \termA \agaga
                expect err .to.be null
                expect result .to.equal \non-existing-party
                done!

        describe 'Approve' ->
            approvalResults = null
            test 'should approve selected terms' (done) ->
                termArray =
                    <[termA ods]>
                    <[termA ods]>
                    <[termA cssd]>
                    <[termA top]>
                    <[termB ods]>
                    <[termD cssd]>
                    <[termE top]>
                (err, results) <~ async.mapSeries do
                    termArray
                    ([term, party], cb)-> shouts.approve term, party, cb
                expect err .to.be null
                approvalResults := results
                done!
            test 'should not approve any records in the repeated termA approval' ->
                expect approvalResults.1 .to.equal 0
            test 'should approve some terms in all other cases' ->
                approvalResults.forEach (result, index) ->
                    expect result .to.be.greaterThan 0 if index != 1

        describe 'Create after Approval' ->
            test 'should return "ok" return code' ->
                (err, result) <~ shouts.save ip, \termA \top
                expect result .to.equal \ok

        describe 'Retrieve - general' ->
            allTerms = null
            test 'should retrieve all approved terms, sorted' (done) ->
                (err, results) <~ shouts.getAll
                allTerms := results
                expect err .to.be null
                expect results.0.term .to.equal \termA
                expect results.1.term .to.equal \termB
                done!

            test 'not approved terms should not be retrieved' ->
                terms = allTerms.map (.term)
                expect terms .to.not.contain \termC

            test 'retrieved terms should have correct scores' ->
                expect allTerms.0.score .to.equal 3
                expect allTerms.1.score .to.equal 2

        describe 'Retrieve - by party' ->
            partyTerms = null
            test 'should retrieve scored results by party' (done) ->
                (err, results) <~ shouts.get \ods
                expect err .to.be null
                partyTerms := results
                expect results .to.have.length 2
                expect results.0.term .to.equal \termB
                expect results.0.score .to.equal 2
                expect results.1.term .to.equal \termA
                expect results.1.score .to.equal 1
                done!
        describe 'Retrieve - all words with party information' ->
            test 'should retrieve in proper format' (done) ->
                (err, results) <~ shouts.getAllByParty!
                expect err .to.be null
                expect results .to.be.an \array
                expect results .to.have.length 6
                expect results[0].term .to.equal \termB
                expect results[0].party .to.equal \ods
                done!

        describe 'Unapproved and banned shouts' ->
            test 'should retrieve unapproved shouts' (done) ->
                (err, unapproved) <~ shouts.getUnapproved
                expect err .to.be null
                expect unapproved .to.have.length 1
                expect unapproved.0 .to.have.property \term \termC
                expect unapproved.0 .to.have.property \partyId \ods
                expect unapproved.0 .to.have.property \score 1
                done!

            test 'should ban shouts' (done) ->
                (err, unapproved) <~ shouts.ban \termC \ods
                expect err .to.be null
                (err, unapproved) <~ shouts.getUnapproved
                expect unapproved .to.have.length 0
                done!


    describe 'Antispam' ->
        test 'Shout should be querying Antispam for permission to vote' ->
            expect antispamMock.requests .to.have.length 5
            expect antispamMock.requests.0.ip .to.equal ip

        test 'shout should not insert terms if antispam is blocking it' (done) ->
            antispamResult := no
            (err, result) <~ shouts.save ip, \termA \cssd
            expect err .to.be null
            expect result .to.equal \blocked
            done!

    describe 'Case insensitivity' ->
        test 'all terms should be case insensitive' (done) ->
            antispamResult := yes
            (err, result) <~ shouts.save \127.0.0.2 \terma \termb \ods
            expect err .to.be null
            (err, result) <~ shouts.get \ods
            expect result.0 .to.have.property \term \termB
            expect result.0 .to.have.property \score 3
            expect result.1 .to.have.property \term \termA
            expect result.1 .to.have.property \score 2
            done!
