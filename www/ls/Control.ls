window.Control = class Control
    (@data, @$container, @wordCloudFactory) ->
        @drawSelector!
        @wordCloud = @prepareWordCloud!
        @drawParty \all

    drawSelector: ->
        @$selector = $ "<ul></ul>"
            ..addClass \selector
        for _party of @data
            continue if _party is \all
            let party = _party
                $ "<li></li>"
                    ..html party
                    ..appendTo @$selector
                    ..on \click ~> @drawParty party
        @$selector.appendTo @$container

    drawParty: (partyId) ->
        @$wordCloud.removeClass @lastPartyId if @lastPartyId
        @$wordCloud.addClass partyId
        @wordCloud.draw @data[partyId]
        @lastPartyId = partyId

    prepareWordCloud: ->
        @$wordCloud = $ "<div></div>"
            ..addClass \wordCloud
            ..appendTo @$container
        @wordCloudFactory @$wordCloud
