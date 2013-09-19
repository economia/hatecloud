parties =
    top:
        name: \TOP09

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

control
    ..drawParty \ods
    ..onTermClicked!
