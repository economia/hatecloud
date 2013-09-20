require! {
    Cloud: 'd3.layout.cloud'.cloud
    Canvas: "canvas"
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

    generatePNGBuffer: (words, {width, height, colors}:options, cb) ->
        require! canvg
        (err, wordcloud) <~ @generate words, options
        return cb err if err
        svg = @getSVG wordcloud, options
        canvas = new Canvas!
        canvg canvas, svg
        cb null canvas.toBuffer!

    getSVG: (words, {width, height, colors}:colors) ->
        texts = for it in words
            """<text
                font-size='#{it.size}px'
                font-family='Impact'
                fill='#{colors[it.className] || 'black'}'
                text-anchor='middle'
                transform='translate(#{it.x}, #{it.y}) rotate(#{it.rotate * 90})'
                >#{it.text}</text>"""

        "
        <svg width='#{width}' height='#{height}' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>
        <g transform='translate(#{width / 2},#{height / 2})'>
            #{texts.join ''}
        </g>
        </svg>"
