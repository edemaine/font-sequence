charHeight = 19

window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 1
    lineKern: 10
    afterMaybeRender: (state, changed) ->
      if not changed? or changed.dotColor or changed.lineColor or changed.lines
        document.getElementById('state').innerHTML = """
          circle { fill: #{state.dotColor} }
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
          points.push [x, charHeight - y]
          x++
      if state.dots
        for point in points
          g.circle state.dots
          .center ...point
      if state.lines
        g.polyline points
      x: -0.5
      y: -0.5
      element: g
      width: x
      height: charHeight + 1

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'sequence.svg'
