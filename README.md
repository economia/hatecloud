# Hatecloud
Generátor wordcloud-like anket. Používá node.js a redis. Napsaný v [LiveScriptu](http://livescript.net/) (lze překompilovat do js přes *slake deploy*).

## Instalace

    npm install -g LiveScript
    git clone git@github.com:economia/hatecloud.git
    cd hatecloud
    npm install

Na Windows mašinách bude potřeba si naklonovat [d3.layout.cloud](https://github.com/jasondavies/d3-cloud) a v package.json změnit canvas dependecy na vyšší verzi (aktuální 1.1.2 funguje).

Pro obrázek je potřeba mít na systému nainstalovaný font - defaultně impact. Na Linuxu viz [wiki](http://wiki.ubuntu.cz/instal%C3%A1cia_nov%C3%BDch_fontov).

## Výstupy
Generují se dva wordcloudy, velký jako JSON definice, malý jako obrázek (přístupný na /img/cloud.png).

JSON je k dispozici na /term a obsahuje klíče pro každé ID strany a kombinovaný "all". To obsahuje pole s velikostí, souřadnicemi (od středu canvasu, ne levý horní roh), textem a příznakem rotace (zda je otočený o 90°).

## Config
Zkopírujte config.example.ls do config.ls. Bude potřeba nastavit:
*   adresu redisu, případně port
*   parties (IDčka možností)
*   povolené IP pro administraci
*   rozměry "velkého" wordcloudu
*   interval, jak často se má wordcloud generovat ( = pauza mezi generováním)
*   rozměry "malého" wordcloudu a barvy fontů jednotlivých stran

## Příprava
Skript src/init.ls obsahuje funkci k úvodnímu naplnění cloudu "vykopávacími" slovy. Je pouze v master větvi, do starších větví si ho cherry-pickněte nebo zkopírujte, nemělo by to způsobit velké mrzení.

## Spuštění
Po kompilaci (Slake deploy) přes node lib/base.js.

## Varianty (branche)
*   HateCloud - první verze cloudu, "proč nevolit stranu". Výběr ze 3 slov
*   LoveCloud - druhá verze, výběr ze 3 slov, asi nějaká vylepšení. Doporučená veze pro víceslovné cloudy
*   PostCoitCloud - povolební cloud "postcoitální deprese". Pouze jedno slovo a frontend ohackován na pouze jednu stranu. Barvy slov se určují náhodným výběrem.
*   master - 12-13Cloud - cloud "rok 2012/13 jedním slovem". Jedno slovo, možnost v adminu zaškrtnout "mood" slova a na jeho základě upravit barvu ve výpisu, ale mood nakonec použit nebyl. Doporučená verze pro jednoslovné cloudy.

## Testy
Něco málo je na serveru pokryto mocha testy. Mají vlastní config, v /test/config.ls, strukturou odpovídá produkčnímu configu.
