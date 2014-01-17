window.Control = class Control
    (@data, @$container, @wordCloudFactory, @formFactory, @voteWatch, @parties) ->
        @drawSelector!
        @wordCloud = @prepareWordCloud!
        @form = @prepareForm!
        @drawParty \ods
        @drawAddTermButton!
        @registerClickHandlers!

    drawSelector: ->
        @$selector = $ "<ul></ul>"
            ..addClass \selector
        _index = 0
        for _party of @data
            continue if _party is \all
            let party = _party
                index = _index++
                item = $ "<li></li>"
                    ..addClass "sel-#party"
                    ..append @parties[party].name
                    ..append "<div class='arrow'></div>"
                    ..appendTo @$selector
                    ..on \click ~>
                        if index >= 7
                            @$selector.addClass "secondHalf"
                        else
                            @$selector.removeClass "secondHalf"
                        @$selector.removeClass \expanded
                        @$selector.find '.active' .removeClass \active
                        item.addClass \active
                        @drawParty party
                item.addClass \active if party == \2013

        @$selector.appendTo @$container

    drawParty: (partyId) ->
        return if partyId is @curentPartyId
        @form.hide!
        @$wordCloud.removeClass @curentPartyId if @curentPartyId
        @$wordCloud.addClass partyId
        switch @voteWatch.didVote partyId
        | yes => @$wordCloud.addClass \voted
        | no  => @$wordCloud.removeClass \voted
        @wordCloud.draw @data[partyId]
        @curentPartyId = partyId

    prepareWordCloud: ->
        @$wordCloud = $ "<div></div>"
            ..addClass \wordCloud
            ..appendTo @$container
        $wordCloudSubcontainer = $ "<div></div>"
            ..addClass \subcontainer
            ..appendTo @$wordCloud
        @wordCloudFactory $wordCloudSubcontainer

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
            alertify.error "Již jste hlasoval"
        | no
            out = {terms, party: @curentPartyId}
            request = $.post "./term" out
            request.fail ->
                switch it.status
                | 403 => alertify.error "Již jste hlasoval"
                | 404 => alertify.error "Zadali jste neexistující stranu. To by nešlo."
                | _   => alertify.error "Omlouváme se, ale v aplikaci nastala chyba. Zkuste to prosím později."
            request.done ~>
                alertify.success "Děkujeme, vaše hlasování proběhlo v pořádku"
                @voteWatch.registerVote party


    onTermClicked: (term = null, element) ->
        | @curentPartyId is \all
            party = if Modernizr.svg
                element.getAttribute 'class'
            else
                $ element .data \party
            return if not @parties[party]
            $ "li.sel-#party" .addClass \active
            @drawParty party
            @onTermClicked term
        | otherwise
            switch @voteWatch.didVote @curentPartyId
            | yes => alertify.error "Již jste hlasoval"
            | no  => if term then @form.addTerm term else @form.display!

    registerClickHandlers: ->
        $ document .on 'click touchstart' '.wordCloud .subcontainer text' (evt) ~>
            @onTermClicked evt.currentTarget.textContent, evt.currentTarget
        $ document .on 'click touchstart' '.wordCloud .subcontainer span' (evt) ~>
            @onTermClicked evt.currentTarget.innerHTML, evt.currentTarget

    drawHelpButton: ->
        $ "<div></div>"
            ..addClass 'button help'
            ..html "<span>?</span><em>nápověda</em>"
            ..attr \data-tooltip escape "<p>Dokážete si v současné situaci vybrat jednu z kandidujících stran, aniž byste si museli říct, že volíte „nejmenší zlo“? Jaké jsou důvody, kvůli kterým jste ochotni dát svoji důvěru jedné politické straně? V aplikaci serveru IHNED.cz můžete u každé strany, která má reálnou šanci dostat se do parlamentu, vybrat tři důvody, díky kterým má pro vás volba strany smysl.</p>
                <p>Klikněte na logo strany, objeví se vám nejčastěji zmiňované důvody ostatních lidí. Vyberte z nabídky slov ta, která nejlépe reprezentují váš názor. Nebo zvolte možnost „přidat slovo“ a zadejte vlastní slova. Můžete navolit až 3 jednoslovné důvody nebo je kombinovat s těmi z nabídky. <em>(Redakce si vyhrazuje právo vyřadit nebo upravit nevhodné a vulgární výrazy)</em>.</p>"
            ..appendTo @$wordCloud

    drawAddTermButton: ->
        $ "<div></div>"
            ..addClass 'button add'
            ..html "<span>+</span><em>přidat slovo</em>"
            ..appendTo @$wordCloud
            ..on \click ~> @onTermClicked!
