require! {
    expect : "expect.js"
    '../src/WordCloud'
    async
    fs
}
test = it
describe 'WordCloud' ->
    wordCloud = new WordCloud
    test 'should generate output' (done) ->
        words_party =
            top  : <[Kalousek Kníže Spánek Gripeny Šlechta Přeběhlictví Arogance Škrty Elity Korupce ]>
            ods  : <[ Nagygate Kmotři Minulost Nedůvěra Zklamání Nejistota Korupce Podnikatelé  Němcová Daně]>
            cssd : <[Nejdnostnost Sobotka Levicovost Hašek Socialismus Populismus Plýtvání Daně Komunisté Nemodernost]>
            kscm : <[Minulost Nomenklatura Totalita Komunismus Osmačtyřicátý Osmašedesátý Zastaralost Znárodnění Strach Nedůvěra]>
            ano  : <[KSČ Podnikatel Babiš Peníze Populismus Berlusconizace Nedůvěryhodnost Účelovost Diktátor Program]>
            spoz : <[Zeman Nejednotnost Šlouf Kancléř Účelovost Lukoil Papaláš Populismus Nečitelnost Pochybnost]>
            kdu  : <[Otazníky Konzervatismus Křešťanství Nestálost Osobnosti Nejasnost Čunek Prodejnost Nevýraznost Nemodernost]>
            sz   : <[Levicovost Nečitelnost Osobnosti Marnost Ekologie Program Nezkušenost Zklamání Energetika  Radikalismus]>
        words = for strana, words of words_party
            words.map ->
                text: it
                size: 5 + Math.random! * 90
                party: strana

        words = [].concat ...words
        (err, svg) <~ wordCloud.generate words, width: 650 height: 650
        expect svg .to.be.an \array
        expect svg.length .to.be.greaterThan 10
        done!
