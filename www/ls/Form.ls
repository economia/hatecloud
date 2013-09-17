window.Form = class Form implements jQuery.eventEmitter
    (@$container) ->
        @createDom!
        @displayed = no

    addTerm: (term) ->
        @display! unless @displayed
        maxIndex = @$inputs.length - 1
        for index, $input of @$inputs
            index = parseInt index, 10
            if $input.val! in ['', term] or index == maxIndex
                $input.val term
                break
        @$element

    createDom: ->
        @$element = $ "<form></form>"
        @$inputs = for i in [1 to 3]
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
        for $input in @$inputs then $input.val ""

    submit: (evt) ->
        evt.preventDefault!
        values = for $input in @$inputs
            $input.val!
        @emit \submit values
        @hide!
