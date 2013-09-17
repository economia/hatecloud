require! {
    Cloud: 'd3.layout.cloud'.cloud
}

module.exports = class WordCloud
    ->
    generate: (words, {width, height}:options, cb) ->
        cloud = Cloud!
            ..size [width, height]
            ..words words
            ..padding 5
            ..rotate -> if Math.floor Math.random! * 2 then 0 else 90
            ..font \Impact
            ..fontStyle ->
                style =
                    className: it.party
                    toString: -> "normal"
                style
            ..spiral \rectangular
            ..fontSize (.size)
            ..on \end ~> @draw it, options, cb
            ..start!

    draw: (words, {width, height}:options, cb) ->
        output = words.map ->
            output = {}
            output{size, x, y, text} = it
            if it.style.className then output.className = it.style.className
            output.rotate = it.rotate == 90
            output
        cb null output
