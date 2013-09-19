window.Control = class Control
    (@data, @$container, @wordCloudFactory, @formFactory, @voteWatch, @parties) ->
        @drawSelector!
        @wordCloud = @prepareWordCloud!
        @form = @prepareForm!
        @drawParty \all
        @drawHelpButton!
        @drawAddTermButton!
        @registerClickHandlers!

    drawSelector: ->
        @$selector = $ "<ul></ul>"
            ..addClass \selector
        for _party of @data
            continue if _party is \all
            let party = _party
                item = $ "<li></li>"
                    ..append "<img src='img/loga/#{party}-on.png' class='on' alt='Logo #{@parties[party].name}' title='#{@parties[party].name}' />"
                    ..append "<img src='img/loga/#{party}-off.png' class='off' alt='Logo #{@parties[party].name}' title='#{@parties[party].name}' />"
                    ..append @parties[party].name
                    ..append "<div class='arrow'></div>"
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
            alertify.error "Pro tuto stranu jste již volil"
        | no
            out = {terms, party: @curentPartyId}
            request = $.post "./term" out
            request.fail ->
                switch it.status
                | 403 => alertify.error "Pro tuto stranu jste již hlasoval"
                | 404 => alertify.error "Zadali jste neexistující stranu. To by nešlo."
                | _   => alertify.error "Omlouváme se, ale v aplikaci nastala chyba. Zkuste to prosím později."
            request.done ~>
                alertify.success "Děkujeme, vaše hlasování proběhlo v pořádku"
                @voteWatch.registerVote party


    onTermClicked: (term = null) ->
        return if @curentPartyId is \all
        switch @voteWatch.didVote @curentPartyId
        | yes => alertify.error "Pro tuto stranu jste již volil"
        | no  => if term then @form.addTerm term else @form.display!

    registerClickHandlers: ->
        $ document .on \click '.wordCloud text' (evt) ~>
            @onTermClicked evt.currentTarget.textContent
        $ document .on \click '.wordCloud span' (evt) ~>
            @onTermClicked evt.currentTarget.innerHTML

    drawHelpButton: ->
        $ "<div></div>"
            ..addClass 'button help'
            ..html "<span>?</span><em>nápověda</em>"
            ..attr \data-tooltip escape "<p>Dokážete si v současné situaci vybrat jednu z kandidujících stran, aniž byste si museli říct, že volíte „nejmenší zlo“? Proč jsou pro vás volby problematické? Jaké jsou důvody, kvůli kterým váháte nebo už dokonce víte, že svůj hlas neodevzdáte? V aplikaci serveru IHNED.cz můžete u každé strany, která má reálnou šanci dostat se do sněmovny, vybrat tři důvody, kvůli nimž je pro vás nepřijatelná.</p>
                <p>Klikněte na logo strany, objeví se vám nejčastěji zmiňované důvody ostatních lidí. Vyberte kliknutím nabízená slova ta, která nejvíce reprezentuje váš názor. Nebo zvolte možnost „přidat slovo (vlevo dole) a zadejte vlastní slova. Můžete navolit maximálně tři důvody a kombinovat slova v nabídce s vlastními výrazy. <em>(Redakce si vyhrazuje právo vyřadit nebo upravit nevhodné a vulgární výrazy)</em>.</p>"
            ..appendTo @$wordCloud

    drawAddTermButton: ->
        $ "<div></div>"
            ..addClass 'button add'
            ..html "<span>+</span><em>přidat slovo</em>"
            ..appendTo @$wordCloud
            ..on \click ~> @onTermClicked!

