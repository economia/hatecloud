window.Form = class Form implements jQuery.eventEmitter
    (@$container) ->
        @createDom!
        @displayed = no

    addTerm: ->
        @display! unless @displayed


    createDom: ->
        @$element = $ "<form></form>"
        for i in [1 to 3]
            $input = $ "<input type='text' />"
                ..appendTo @$element
        $submit = $ "<input type='submit' value='Odeslat' />"
            ..appendTo @$element
            ..on \click @~submit

        @$element.appendTo @$container

    display: ->
        @$element.addClass \displayed
        @displayed = yes

    hide: ->
        return unless @displayed
        @$element.removeClass \displayed
        @displayed = no
        @clear!

    clear: ->
        @$element.find 'input[type=text]' .val ""

    submit: ->
        console.log 'submitted'
