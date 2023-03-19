charHeight = 19
charDepth = 5
dotOutlineRatio = 0.25
axisExtension = 5
arrowSize = 2.5

mapY = (y) => charHeight - y

window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 1
    lineKern: 5
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
      changed.dotColor or
      changed.lineColor or
      changed.axisColor
    renderLine: (line, state, group) ->
      g = group.group()
      x = 0
      points = []
      for char in line
        char = char.toUpperCase()
        continue unless char of window.font
        glyph = window.font[char]
        for y in glyph
          points.push point = [x, mapY y]
          point.negative = true if y < 0
          x++
      glyph =
        x: -0.5
        y: -0.5
        element: g
        width: x
        height: charHeight + charDepth + 1
      if state.axes
        bottom = mapY -charDepth
        g.line -axisExtension, bottom, x + axisExtension, bottom
        glyph.x -= axisExtension + arrowSize * state.axes
        glyph.width += 2 * axisExtension + arrowSize * state.axes + state.axes / 2
        g.line -axisExtension, bottom, -axisExtension, -axisExtension
      if state.dots
        for point in points
          circle = g.circle state.dots * (if point.negative then 1 - dotOutlineRatio/2 else 1)
          .center ...point
          circle.addClass 'negative' if point.negative
      if state.lines
        g.polyline points
      glyph

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'sequence.svg'
