window.WordList = class WordList
    @list = null
    (wordCloudData) ->
        @list = []
        for party, words of wordCloudData
            for {text:word} in words
                if word not in @list then @list.push word
