require! async
module.exports = class WordCloudDataConnector
    roundRobinIndex: 0
    (@shouts, @wordCloud, @outputCache,{shouts, wordCloud}:config) ->
        @config = config

    loadFirstData: (cb) ->
        (err, terms) <~ @shouts.getAllByParty!
        return console.error err if err
        tasks = []
        tasks.push (cb) ~> @generateGlobalCloud terms, cb
        tasks.push (cb) ~> @generateGlobalCloudImage terms, cb
        tasks ++= @config.shouts.parties.map (party) ~>
            partyTerms = terms.filter -> it.party == party
            (cb) ~> @generatePartyCloud partyTerms, party, cb
        (err) <~ async.parallel tasks
        cb? err


    generateNextCloud: ->
        if @roundRobinIndex > @config.shouts.parties.length
            @roundRobinIndex = 0
        party = @config.shouts.parties[@roundRobinIndex]
        if party
            @refreshParty party
        else
            @refreshGlobal!
        @roundRobinIndex++


    refreshGlobal: ->
        (err, terms) <~ @shouts.getAllByParty!
        switch
        | err => console.error err
        | otherwise
            @generateGlobalCloud terms
            @generateGlobalCloudImage terms


    refreshParty: (party) ->
        (err, terms) <~ @shouts.get party
        switch
        | err => console.error err
        | _   => @generatePartyCloud terms, party


    generateGlobalCloud: (terms, cb) ->
        @wordCloud.generate do
            @convertToWords @config.wordCloud, terms
            @config.wordCloud
            (err, cloud) ~>
                | err => console.error err
                | _   => @outputCache.set cloud, null
                cb? err

    generateGlobalCloudImage: (terms, cb) ->
        @wordCloud.generatePNGBuffer do
            @convertToWords @config.wordCloud.smallCloud, terms
            @config.wordCloud.smallCloud
            (err, buff) ~>
                | err => console.error err
                | _   => fs.writeFile "#__dirname/../www/img/cloud.png" buff
                cb? err



    generatePartyCloud: (terms, party, cb) ->
        @wordCloud.generate do
            @convertToWords @config.wordCloud, terms, party
            @config.wordCloud
            (err, cloud) ~>
                | err => console.error err
                | _   => @outputCache.set cloud, party
                cb? err


    convertToWords: (sizes, terms, party = null) ->
        maxScore = Math.max ...terms.map (.score)
        words = terms.map ~>
            word =
                text : it.term
                size: @computeSize sizes, maxScore, it.score
            if it.party then word.party = that
            word


    computeSize: (sizes, maxScore, score) ->
        sizes.minSize + sizes.maxSize * Math.sqrt score / maxScore
