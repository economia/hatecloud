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
            ..spiral \rectangular
            ..fontSize (.size)
            ..on \end ~> @draw it, options, cb
            ..start!

    draw: (words, {width, height}:options, cb) ->
        texts = words.map ->
            """<text
                font-size='#{it.size}px'
                font-family='Impact'
                fill='red'
                text-anchor='middle'
                transform='translate(#{it.x}, #{it.y}) rotate(#{it.rotate})'
                >#{it.text}</text>"""

        svg = '<?xml version="1.0" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
        svg += "
        <svg width='#width' height='#height' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>
        <g transform='translate(#{width/2},#{height/2})'>
            #{texts.join ''}
        </g>
        </svg>"
        cb null svg


