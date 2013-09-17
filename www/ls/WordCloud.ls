window.WordCloud = class WordCloud
    (@$container) ->

    draw: (words) ->
        @$container.html @getSVG words

    getSVG: (words) ->
        texts = for it in words
            """<text
                font-size='#{it.size}px'
                font-family='Impact'
                class='#{it.className || ''}'
                text-anchor='middle'
                transform='translate(#{it.x}, #{it.y}) rotate(#{it.rotate * 90})'
                >#{it.text}</text>"""

        "
        <svg width='650' height='650' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>
        <g transform='translate(325,325)'>
            #{texts.join ''}
        </g>
        </svg>"

