(data) <~ $.getJSON "./term"
control = new Control do
    data
    $ '#content'
    -> new WordCloud ...
    -> new Form ...
    new VoteWatcher
