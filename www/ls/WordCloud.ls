window.WordCloud = class WordCloud
    (@$container) ->
        @colors = <[1B9E77 D95F02 7570B3 E7298A 66A61E E6AB02]>
        @width = @$container.width!
        @height = @$container.height!

    draw: (words) ->
        | Modernizr.svg => @drawSVG words
        | otherwise     => @drawHTML words

    drawSVG: (words) ->
        @$container.html @getSVG words

    drawHTML: (words) ->
        @$container.html @getHTML words
        @$container.find 'span' .each ->
            $ele = $ @
            width = $ele.width!
            height = $ele.height!
            x = +$ele.data 'x'
            y = +$ele.data 'y'
            if $ele.hasClass \rot
                width *= 0.8
            $ele.css \left x - width / 2
            $ele.css \top y - height / 2


    getSVG: (words) ->
        texts = for it in words
            color = @colors[Math.floor Math.random! * @colors.length]
            """<text
                font-size='#{it.size}px'
                font-family='Impact'
                style="fill:#{color}"
                text-anchor='middle'
                transform='translate(#{it.x}, #{it.y}) rotate(#{it.rotate * 90})'
                >#{it.text}</text>"""

        "
        <svg width='#{@width}' height='#{@height}' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>
        <g transform='translate(#{@width / 2},#{@height / 2})'>
            #{texts.join ''}
        </g>
        </svg>"

    getHTML: (words) ->
        texts = for it in words
            """<span style='font-size:#{it.size}px;
                font-family:Impact;
                position:absolute;
                left: #{it.x}px;
                top: #{it.y}px;'
                class='#{it.className || ''} #{if it.rotate then 'rot' else ''} text'
                data-party='#{it.className}'
                data-x='#{it.x}'
                data-y='#{it.y}'
                >#{it.text}</span>"""

        "<div style='position: absolute; top: #{@width / 2}px;left: #{@height / 2}px'>
            #{texts.join ''}
        </div>"

