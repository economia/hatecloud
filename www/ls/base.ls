(data) <~ $.getJSON "./temp/all.json"
control = new Control do
    data
    $ '#content'
    -> new WordCloud ...
    -> new Form ...
# wordCloud.draw data.all
