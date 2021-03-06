window.Form = class Form implements jQuery.eventEmitter
    (@autocompleteList, @$container) ->
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

    createDom: ->
        @$element = $ "<form></form>"
        $cancelButton = $ "<div></div>"
            ..addClass 'button cancel'
            ..appendTo @$element
            ..html "<span>+</span><em>zrušit</em>"
            ..on \click (evt) ~>
                evt.preventDefault!
                @hide!
        @$inputs = for i in [1]
            $pair = $ "<div></div>"
                ..addClass \pair
            $ "<label for='reason-#i'></label>"
                ..html ""
                ..appendTo $pair
            $input = $ "<input type='text' id='reason-#i' />"
                ..appendTo $pair
                ..autocomplete source: @autocompleteList
            $pair.appendTo @$element
            $input
        $submit = $ "<input type='submit' value='Odeslat' />"
            ..appendTo @$element
            ..on \click @~submit

        @$element.appendTo @$container
