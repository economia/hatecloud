module.exports = class WordCloudDataConnector
    roundRobinIndex: 0
    (@shouts, @wordCloud, @outputCache,{shouts, wordCloud}:config) ->
        @config = config

    loadFirstData: ->
        (err, terms) <~ @shouts.getAllByParty!
        return console.error err if err
        @generateGlobalCloud terms
        @generateGlobalCloudImage terms
        @config.shouts.parties.forEach (party) ~>
            partyTerms = terms.filter -> it.party == party
            @generatePartyCloud partyTerms, party


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


    generateGlobalCloud: (terms) ->
        @wordCloud.generate do
            @convertToWords @config.wordCloud, terms
            @config.wordCloud
            (err, cloud) ~>
                | err => console.error err
                | _   => @outputCache.set cloud, null

    generateGlobalCloudImage: (terms) ->
        @wordCloud.generatePNGBuffer do
            @convertToWords @config.wordCloud.smallCloud, terms
            @config.wordCloud.smallCloud
            (err, buff) ~>
                | err => console.error err
                | _   => fs.writeFile "#__dirname/../www/img/cloud.png" buff



    generatePartyCloud: (terms, party) ->
        @wordCloud.generate do
            @convertToWords @config.wordCloud, terms, party
            @config.wordCloud
            (err, cloud) ~>
                | err => console.error err
                | _   => @outputCache.set cloud, party


    convertToWords: (sizes, terms, party = null) ->
        maxScore = Math.max ...terms.map (.score)
        words = terms.map ~>
            word =
                text : it.term
                size: @computeSize sizes, maxScore, it.score
            if it.party then word.party = that
            word


    computeSize: (sizes, maxScore, score) ->
        sizes.minSize + sizes.maxSize * score / maxScore
