window.Control = class Control
    (@data, @$container, @wordCloudFactory, @formFactory, @voteWatch) ->
        @drawSelector!
        @wordCloud = @prepareWordCloud!
        @form = @prepareForm!
        @drawParty \all
        @registerClickHandlers!

    drawSelector: ->
        @$selector = $ "<ul></ul>"
            ..addClass \selector
        for _party of @data
            continue if _party is \all
            let party = _party
                item = $ "<li></li>"
                    ..html party
                    ..appendTo @$selector
                    ..on \click ~>
                        @$selector.find '.active' .removeClass \active
                        item.addClass \active
                        @drawParty party
        @$selector.appendTo @$container

    drawParty: (partyId) ->
        return if partyId is @curentPartyId
        @form.hide!
        @$wordCloud.removeClass @curentPartyId if @curentPartyId
        @$wordCloud.addClass partyId
        @wordCloud.draw @data[partyId]
        @curentPartyId = partyId

    prepareWordCloud: ->
        @$wordCloud = $ "<div></div>"
            ..addClass \wordCloud
            ..appendTo @$container
        @wordCloudFactory @$wordCloud

    prepareForm: ->
        @$form = $ "<div></div>"
            ..addClass \form
            ..appendTo @$container
        @formFactory @$form
            ..on \submit @~onNewTerms

    onNewTerms: (evt, ...terms) ->
        party = @curentPartyId
        switch @voteWatch.didVote party
        | yes
            alertify.error "Pro tuto stranu jste již volil"
        | no
            alertify.success "Děkujeme, vaše hlasování proběhlo v pořádku"
            @voteWatch.registerVote party


    onTermClicked: (term) ->
        return if @curentPartyId is \all
        @form.addTerm term

    registerClickHandlers: ->
        $ document .on \click '.wordCloud text' (evt) ~>
            @onTermClicked evt.currentTarget.textContent
        $ document .on \click '.wordCloud span' (evt) ~>
            @onTermClicked evt.currentTarget.innerHTML

