window.Control = class Control
    (@data, @$container, @wordCloudFactory, @formFactory) ->
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

    onTermClicked: (term) ->
        @form.addTerm term

    registerClickHandlers: ->
        $ document .on \click '.wordCloud text' (evt) ~>
            @onTermClicked evt.currentTarget.textContent
        $ document .on \click '.wordCloud span' (evt) ~>
            @onTermClicked evt.currentTarget.innerHTML

