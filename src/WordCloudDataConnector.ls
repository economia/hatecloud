module.exports = class WordCloudDataConnector
    roundRobinIndex: 0
    (@shouts, @wordCloud, @outputCache,{shouts, wordCloud}:config) ->
        @config = config

    loadFirstData: ->
        (err, terms) <~ @shouts.getAllByParty!
        return console.error err if err
        @generateGlobalCloud terms
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
        | _   => @generateGlobalCloud terms


    refreshParty: (party) ->
        (err, terms) <~ @shouts.get party
        switch
        | err => console.error err
        | _   => @generatePartyCloud terms, party


    generateGlobalCloud: (terms) ->
        @wordCloud.generate do
            @convertToWords terms
            @config.wordCloud
            (err, cloud) ~>
                | err => console.error err
                | _   => @outputCache.set cloud, null


    generatePartyCloud: (terms, party) ->
        @wordCloud.generate do
            @convertToWords terms, party
            @config.wordCloud
            (err, cloud) ~>
                | err => console.error err
                | _   => @outputCache.set cloud, party


    convertToWords: (terms, party = null) ->
        maxScore = Math.max ...terms.map (.score)
        words = terms.map ~>
            word =
                text : it.term
                size: @computeSize maxScore, it.score
            if it.party then word.party = that
            word


    computeSize: (maxScore, score) ->
        @config.wordCloud.minSize + @config.wordCloud.maxSize * score / maxScore
