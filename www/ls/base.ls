wordCloud = new WordCloud $ '.cloud'
(data) <~ $.getJSON "./temp/all.json"
wordCloud.draw data.all
