parties =
    "ods":
        name: "ODS"

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
