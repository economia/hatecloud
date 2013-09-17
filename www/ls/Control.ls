window.Control = class Control
    (@data, @$container, @wordCloudFactory) ->
        @drawSelector!

    drawSelector: ->
        @$selector = $ "<ul></ul>"
            ..addClass \selector
        for strana of @data
            $ "<li></li>"
                ..html strana
                ..appendTo @$selector
        @$selector.appendTo @$container

