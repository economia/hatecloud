(data) <~ $.getJSON "./term"
control = new Control do
    data
    $ '#content'
    -> new WordCloud ...
    -> new Form ...
    new VoteWatcher

control.drawParty \kscm
control.onNewTerms null, \Strach \Peníze \Agaga
