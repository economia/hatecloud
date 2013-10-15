parties =
    top:
        name: "TOP 09"
    ods:
        name: \ODS
    cssd:
        name: \ČSSD
    kscm:
        name: \KSČM
    ano:
        name: \ANO
    spoz:
        name: \SPOZ
    kdu:
        name: \KDU-ČSL
    sz:
        name: \SZ
    svobodni:
        name: \Svobodní
    pirati:
        name: \Piráti
    hlvzhuru:
        name: "HL. VZHŮRU"
    rds:
        name: "RDS"
    kan:
        name: "KAN"
    zmena:
        name: "Změna"
    sscr:
        name: "SsČR"
    pb:
        name: "PB"
    suveren:
        name: "Suveren."
    aneo:
        name: "ANEO"
    obc:
        name: "OBČ 2011"
    usvit:
        name: "Úsvit"
    dsss:
        name: "DSSS"
    lev:
        name: "LEV 21"
    kc:
        name: "KČ"



new Tooltip!watchElements!
(data) <~ $.getJSON "./term"
wordList = new WordList data
control = new Control do
    data
    $ '#content'
    -> new WordCloud ...
    (...args)-> new Form wordList.list, ...args
    new VoteWatcher
    parties
