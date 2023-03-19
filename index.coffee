charHeight = 19
charDepth = 5
dotOutlineRatio = 0.25

window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 1
    lineKern: 5
    afterMaybeRender: (state, changed) ->
      if not changed? or changed.dots or changed.dotColor or changed.lineColor or changed.lines
        document.getElementById('state').innerHTML = """
          circle { fill: #{state.dotColor} }
          circle.negative { stroke: #{state.dotColor}; stroke-width: #{state.dots * dotOutlineRatio}; fill: none }
          polyline { stroke: #{state.lineColor}; stroke-width: #{state.lines} }
        """
    shouldRender: (changed) ->
      changed.text or changed.dots or
      (changed.lines and Boolean(changed.lines.value) != Boolean(changed.lines.oldValue)) or
      (changed.dotColor and Boolean(changed.dotColor.value) != Boolean(changed.dotColor.oldValue)) or
      (changed.lineColor and Boolean(changed.lineColor.value) != Boolean(changed.lineColor.oldValue))
    renderLine: (line, state, group) ->
      g = group.group()
      x = 0
      points = []
      for char in line
        char = char.toUpperCase()
        continue unless char of window.font
        glyph = window.font[char]
        for y in glyph
          points.push point = [x, charHeight - y]
          point.negative = true if y < 0
          x++
      if state.dots
        for point in points
          circle = g.circle state.dots * (if point.negative then 1 - dotOutlineRatio/2 else 1)
          .center ...point
          circle.addClass 'negative' if point.negative
      if state.lines
        g.polyline points
      x: -0.5
      y: -0.5
      element: g
      width: x
      height: charHeight + charDepth + 1

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'sequence.svg'
