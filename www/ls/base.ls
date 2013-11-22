parties =
    "2013":
        name: "2013"
    "2014":
        name: "2014"

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
