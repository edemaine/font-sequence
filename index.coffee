charHeight = 19

window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 1
    lineKern: 10
    renderLine: (line, state, group) ->
      unless state.dots or state.lines
        state.dots = true
      g = group.group()
      x = 0
      points = []
      for char in line
        char = char.toUpperCase()
        continue unless char of window.font
        glyph = window.font[char]
        for y in glyph
          if state.dots
            g.circle state.dotSize
            .center x, charHeight - y
          points.push [x, charHeight - y] if state.lines
          x++
      if state.lines
        g.polyline points
        .stroke width: state.lineWidth
      x: -0.5
      y: -0.5
      element: g
      width: x
      height: charHeight + 1

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'cubefolding.svg'
