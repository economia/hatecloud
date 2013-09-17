require! {
    expect : "expect.js"
    '../src/WordCloud'
    async
    fs
}
test = it
describe 'WordCloud' ->
    wordCloud = new WordCloud
    test 'should generate some SVG' (done) ->
        words = <[Kalousek Kníže Spánek Gripeny Šlechta Přeběhlictví Arogance Škrty Elity Korupce Nagygate Kmotři Minulost Nedůvěra Zklamání Nejistota Korupce Podnikatelé  Němcová Daně Nejdnostnost Sobotka Levicovost Hašek Socialismus Populismus Plýtvání Daně Komunisté Nemodernost Minulost Nomenklatura Totalita Komunismus Osmačtyřicátý Osmašedesátý Zastaralost Znárodnění Strach Nedůvěra KSČ Podnikatel Babiš Peníze Populismus Berlusconizace Nedůvěryhodnost Účelovost Diktátor Program Zeman Nejednotnost Šlouf Kancléř Účelovost Lukoil Papaláš Populismus Nečitelnost Pochybnost Otazníky Konzervatismus Křešťanství Nestálost Osobnosti Nejasnost Čunek Prodejnost Nevýraznost Nemodernost Levicovost Nečitelnost Osobnosti Marnost Ekologie Program Nezkušenost Zklamání Energetika  Radikalismus]>
            .map ->
                text: it
                size: 5 + Math.random! * 90
        (err, svg) <~ wordCloud.generate words, width: 600 height: 100
        expect err .to.be null
        expect svg .to.be.a \string
        expect svg.length .to.be.greaterThan 500
        done!
