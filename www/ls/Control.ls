window.Control = class Control
    (@data, @$container, @wordCloudFactory) ->
        @drawSelector!
        @wordCloud = @prepareWordCloud!
            ..draw @data.all


    drawSelector: ->
        @$selector = $ "<ul></ul>"
            ..addClass \selector
        for strana of @data
            continue if strana is \all
            $ "<li></li>"
                ..html strana
                ..appendTo @$selector
        @$selector.appendTo @$container

    prepareWordCloud: ->
        $wordCloud = $ "<div></div>"
            ..addClass \wordCloud
            ..appendTo @$container
        @wordCloudFactory $wordCloud
