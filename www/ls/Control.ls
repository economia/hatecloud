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
