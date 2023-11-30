charHeight = 19
charDepth = 5
dotOutlineRatio = 0.25
axisExtension = 5
arrowSize = 2.5

window?.onload = ->
  total = 0
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 1
    lineKern: 8
    afterMaybeRender: (state, changed) ->
      if not changed? or changed.dots or changed.dotColor or changed.lineColor or changed.lines or changed.axes or changed.axisColor
        document.getElementById('state').innerHTML = """
          circle { fill: #{state.dotColor} }
          circle.negative { stroke: #{state.dotColor}; stroke-width: #{state.dots * dotOutlineRatio}; fill: white }
          polyline { stroke: #{state.lineColor}; stroke-width: #{state.lines} }
          line { stroke: #{state.axisColor}; stroke-width: #{state.axes} }
        """
        document.getElementById('arrowPath').setAttribute 'stroke', state.axisColor
    shouldRender: (changed) ->
      changed.text or changed.dots or
      (changed.lines and Boolean(changed.lines.value) != Boolean(changed.lines.oldValue)) or
      changed.axes or
      changed.ticks or
      changed.dotColor or
      changed.lineColor or
      changed.axisColor or
      changed.interrupt
    beforeRender: ->
      document.getElementById('sequence').innerHTML = ''
      total = 0
    afterRender: ->
      span = document.getElementById('sequence').lastChild?.lastChild
      return unless span?
      if span.innerText.endsWith 'so far)'
        span.innerText = span.innerText.replace 'so far', 'total'
    renderLine: (line, state, group) ->
      sequence = []
      g = group.group()
      x = 0
      mapY = (y) => height - y
      points = []
      lines = []
      interrupt = state.lines and state.interrupt
      if line.startsWith '#'
        sequence =
          for num in line[1..].split /\s*[,;]\s*/
            num = parseInt num, 10
            continue if isNaN num
            num
        height = Math.max 0, ...sequence
        depth = -Math.min 0, ...sequence
        for y, x in sequence
          points.push point = [x, mapY y]
          point.negative = true if y < 0
      else
        height = charHeight
        depth = charDepth
        for char, i in line
          if char == ' '
            wordLine = null
          if i == 0
            lines.push wordLine = [] if interrupt == 'word'
          char = char.toUpperCase()
          continue unless char of window.font
          glyph = window.font[char]
          lines.push glyphLine = [] if interrupt == 'letter'
          for y in glyph
            sequence.push y.toString().replace '-', '&minus;'
            points.push point = [x, mapY y]
            point.negative = true if y < 0
            glyphLine?.push point
            wordLine?.push point
            x++
          if char == ' '
            lines.push wordLine = [] if interrupt == 'word'
      text = "<b>Sequence:</b> " + (sequence.join ', ')
      text += " <span class='length'>(#{sequence.length} terms"
      if total
        text += ", #{total + sequence.length} so far"
      total += sequence.length
      text += ")</span>"
      div = document.createElement 'div'
      div.innerHTML = text
      document.getElementById('sequence').appendChild div
      glyph =
        x: -0.5
        y: -0.5
        element: g
        width: x
        height: height + depth + 1
      if state.axes
        bottom = mapY 0
        g.line -axisExtension, bottom, x + axisExtension, bottom
        .addClass 'arrow'
        glyph.x -= axisExtension + arrowSize * state.axes
        glyph.width += 2 * axisExtension + arrowSize * state.axes + state.axes / 2
        g.line -axisExtension, bottom, -axisExtension, -axisExtension
        .addClass 'arrow'
        if state.ticks
          tickLength = 2*state.axes
          for tickY in [0..bottom]
            g.line -axisExtension - tickLength, tickY, -axisExtension, tickY
          for tickX in [0...x]
            g.line tickX, bottom, tickX, bottom + tickLength
      if state.dots
        for point in points
          circle = g.circle state.dots * (if point.negative then 1 - dotOutlineRatio/2 else 1)
          .center ...point
          circle.addClass 'negative' if point.negative
      lines.push points if interrupt == 'row'
      if lines.length
        for line in lines
          g.polyline line
      glyph

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'sequence.svg'
