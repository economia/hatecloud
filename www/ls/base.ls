parties =
    "2013":
        name: "<b>2013</b> jedním slovem"
    "2014":
        name: "<b>2014</b> jedním slovem"

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
