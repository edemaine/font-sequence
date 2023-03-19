dotSize = 1
charHeight = 19

window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 1
    charKern: 0
    lineKern: 10
    spaceWidth: 10
    renderChar: (char, state, group) ->
      char = char.toUpperCase()
      return unless char of window.font
      glyph = window.font[char]
      g = group.group()
      for y, x in glyph
        g.circle dotSize
        .center x + 0.5, charHeight - y + 0.5
      element: g
      width: glyph.length
      height: charHeight + 1

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'cubefolding.svg'
