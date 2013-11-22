require! {
    expect : "expect.js"
    '../src/WordCloud'
    async
    fs
}
test = it
describe 'WordCloud' ->
    shoutsMock =
        store:
            "Kalousek;top" : "negative"
            "Nagygate;ods" : "positive"
        getMood: (term, partyId, cb) ->
            <~ process.nextTick
            key = "#{term};#{partyId}"
            if @store[key]
                cb null that
            else
                cb null null

    wordCloud = new WordCloud shoutsMock
    words_party =
        top  : <[Kalousek Kníže Spánek Gripeny Šlechta Přeběhlictví Arogance Škrty Elity Korupce ]>
        ods  : <[ Nagygate Kmotři Minulost Nedůvěra Zklamání Nejistota Korupce Podnikatelé  Němcová Daně]>
        cssd : <[Nejdnostnost Sobotka Levicovost Hašek Socialismus Populismus Plýtvání Daně Komunisté Nemodernost]>
        kscm : <[Minulost Nomenklatura Totalita Komunismus Osmačtyřicátý Osmašedesátý Zastaralost Znárodnění Strach Nedůvěra]>
        ano  : <[KSČ Podnikatel Babiš Peníze Populismus Berlusconizace Nedůvěryhodnost Účelovost Diktátor Program]>
        spoz : <[Zeman Nejednotnost Šlouf Kancléř Účelovost Lukoil Papaláš Populismus Nečitelnost Pochybnost]>
        kdu  : <[Otazníky Konzervatismus Křešťanství Nestálost Osobnosti Nejasnost Čunek Prodejnost Nevýraznost Nemodernost]>
        sz   : <[Levicovost Nečitelnost Osobnosti Marnost Ekologie Program Nezkušenost Zklamání Energetika  Radikalismus]>
    output = {}
    test 'should generate JSON output without classnames' (done) ->
        parties = []
        tasks = for strana, words of words_party
            parties.push strana
            words.map ->
                text: it
                size: 5 + Math.random! * 90
        (err, clouds) <~ async.map tasks, (words, cb) -> wordCloud.generate words, width: 650 height: 650, cb
        paired = clouds.map (cloud, index) ->
            party = parties[index]
            {cloud, party}
        paired.forEach (pair) -> output[pair.party] = pair.cloud
        done!
    test 'should generate JSON output with classnames by parties' (done) ->
        words = for strana, words of words_party
            words.map ->
                text: it
                size: 5 + Math.random! * 90
                party: strana

        words = [].concat ...words
        (err, cloud) <~ wordCloud.generate words, width: 650 height: 650
        expect cloud .to.be.an \array
        expect cloud.length .to.be.greaterThan 10
        output['all'] = cloud
        done!

    test 'should output PNG image' (done) ->
        words = for strana, words of words_party
            words.map ->
                text: it
                size: 5 + Math.random! * 90
                party: strana

        words = [].concat ...words
        colors =
            kscm: \#e3001a
            cssd: \#f29400
            ods:  \#006ab3
            top:  \#7c0042
            spoz: \#FB9A99
            sz:   \#00AD00
            kdu:  \#FFE03E
            ano:  \#282560
        width = 350
        height = 350
        (err, buffer) <~ wordCloud.generatePNGBuffer words, {colors, width, height}
        expect buffer .to.be.a Buffer
        expect buffer.length .to.be.greaterThan 10
        done!
