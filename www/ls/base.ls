(data) <~ $.getJSON "./temp/all.json"
control = new Control do
    data
    $ '#content'
    -> new WordCloud ...
# wordCloud.draw data.all
