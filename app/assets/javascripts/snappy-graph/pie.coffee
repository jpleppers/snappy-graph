window.snappyPie =
  themes: {}
  count: 1

window.addSnappyPieTheme = (name, options = {}) -> window.snappyPie.themes[name] = options

class @SnappyPie
  constructor: (@element, @options = {}) ->
    @pieId = "snappy-pie-#{window.snappyPie.count}"
    window.snappyPie.count++

    defaults =
      size:                   400
      width:                  '100%'
      sort:                   true
      strokeWidth:            1
      strokeOpacity:          0.5
      hoverStroke:            5
      hoverOpacity:           0.5
      animation:              null
      animationOffset:        0.1
      animationStart:         0.4
      duration:               800
      opacityStart:           0
      opacityEnd:             0
      circleOffset:           40
      background:             'transparent'
      colorTheme:             'bluegreen'
      colors:                 null
      colorsSeparator:        ','
      colorsCycle:            false
      startColor:             null
      endColor:               null
      percentage:             true
      percentageSignificance: 0
      percentageCutoff:       5
      textboxPadding:         5
      legend:                 true
      legendLineheight:       20
      legendPadding:          5

    @options.theme ||= @element.data('theme')

    for key, value of defaults
      # Dont set if it has already been set in options
      unless @options[key]
        if @element.data(key)?
          @options[key] = @element.data(key)
        else if window.snappyPie.themes[@options.theme]? && window.snappyPie.themes[@options.theme][key]?
          @options[key] = window.snappyPie.themes[@options.theme][key]
        else
          @options[key] = value

    @colors =
      bluegreen:  ['0b486b', 'cff09e']
      sun:        ['f91700', 'ffb400']
      bluered:    ['ff0000', '12476e']
      contrast:   ['ff0000', '00ff2a']

    if @options.colors?
      @options.colors = @options.colors.split(@options.colorsSeparator)
    else
      @options.colors = []

    tagStyle = ["width:#{@options.width}#{if typeof(@options.width) == 'number' then 'px' else ''}", "height: #{@options.size}px", (if @options.background? then "background-color: #{@options.background}" else '') ]

    @total = 0
    @center = @options.size / 2
    @radius = @options.size / 2 - @options.circleOffset - @options.strokeWidth - @options.hoverStroke

    @svgContainer = $("<svg id='#{@pieId}' class='snappy-pie' style='#{tagStyle.join('; ')}' viewBox='0 0 1 #{@options.size}' preserveAspectRatio='xMinYMin'>")
    @element.after @svgContainer
    @snap = Snap("##{@pieId}")
    # @background = @snap.rect(0,0 , @options.width, @options.size).attr({fill: @options.background}) if @options.background?

    @legend = @snap.g().attr('class', 'snappy-legend') if @options.legend
    @pieces = @snap.g().attr('class', 'snappy-pieces')

    if @element.is('ul')
      @createAreasFromList()
    else if @element.is('dl')
      @createAreasFromDefinitionList()

    @draw()
    @element.hide()

    @svgContainer.on 'highlight', (event, indexOfPiece) =>
      console.log  indexOfPiece
      @highlightPiece indexOfPiece

    @svgContainer.on 'mouseover', '.snappy-piece', (event) =>
      # Move piece to bottom
      $piece = $(event.currentTarget)
      @highlightPiece $piece.data('value-index')

    @svgContainer.on 'mouseover', '.snappy-legend [data-value-index]', (event) =>
      $legend = $(event.currentTarget)

      # Set hover and move piece to bottom
      @highlightPiece $legend.data('value-index')

    @svgContainer.on 'mouseout', '.snappy-legend [data-value-index]', (event) =>
      $legend = $(event.currentTarget)
      $(".snappy-pieces [data-value-index=#{$legend.data('value-index')}]", @svgContainer).attr({class: 'snappy-piece'})

  highlightPiece: (index) ->
    @removeHighlights()
    $piece = $(".snappy-pieces [data-value-index=#{index}]", @svgContainer)
    $piece.attr({class: 'snappy-piece hover'})
    $piece.appendTo $piece.parent()

  removeHighlights: ->
    $('.snappy-pieces [data-value-index]', @svgContainer).attr({class: 'snappy-piece'})

  valueFromElement: (el) ->
    parseInt $(el).text()

  createAreasFromList: ->
    @values = []
    $('li', @element).each (index, el) =>
      @values.push {value: @valueFromElement(el)}

    @sortAreas()
    @createAreas()

  createAreasFromDefinitionList: ->
    @values = []
    label = ''
    value = ''

    $('> *', @element).each (index, el) =>
      $el = $(el)
      if $el.is('dt')
        label = $el.text()
      else if $el.is('dd')
        value = @valueFromElement(el)

      if label? && label != '' && value? && value != ''
        @values.push {label: label, value: value}
        label = ''
        value = ''

    @sortAreas()
    @createAreas()

  sortAreas: ->
    @values.sort((a,b)-> b.value - a.value) if @options.sort

  createAreas: () ->
    @total = 0
    @total += value.value for value in @values
    @areas = []

    previous = 0
    for value in @values
      start = previous
      end = previous + (value.value * 360 / @total)
      @areas.push
        label: value.label
        value: value.value
        start: start
        end: end
      previous = end

  color: (index) ->
    if @options.colors.length > 0
      index = index % @options.colors.length if @options.colorsCycle
      @options.colors[index]
    else
      startColor  = if @options.startColor? then @options.startColor  else @colors[@options.colorTheme][0]
      endColor    = if @options.endColor?   then @options.endColor    else @colors[@options.colorTheme][1]

      @colorStart = new Color {hex: startColor}
      @colorEnd =   new Color {hex: endColor}
      newColor = @colorStart.mixWith @colorEnd, index / (@areas.length - 1)
      newColor.toRGBstring()

  draw: ->
    switch @options.animation
      when 'grow'
        offset = @radius * @options.animationOffset
        start = @radius * @options.animationStart
        end = (@radius + @areas.length * offset)

        Snap.animate start, end, ((i) => @drawPieces({radius: i, offset: offset})), @options.duration, mina.easein
      when 'swing'
        Snap.animate 0, 1, ((i) => @drawPieces({radialMultiplier: i})), @options.duration, mina.easein
      else
        @drawPieces()

    @drawLegend() if @options.legend

  drawPieces: (options={}) ->
    radius = options.radius || @radius
    offset = options.offset || 0
    radialMultiplier = options.radialMultiplier || 1

    $('.snappy-piece', @svgContainer).remove()

    for value, index in @areas
      startDegree = value.start * radialMultiplier
      endDegree = value.end * radialMultiplier
      midDegree = endDegree - (endDegree - startDegree) / 2
      normRadius = @minMax(0, radius - (index * offset), @radius)
      percentage = (value.value / @total * 100).toFixed(@options.percentageSignificance)

      textPosition = @degreeToCoords midDegree, normRadius / 1.4
      textboxPosition = @degreeToCoords midDegree, normRadius

      piece = @snap.g().attr({class: 'snappy-piece', 'data-value-index': index})

      # Actual pie piece
      piece.add @piece(startDegree, endDegree, normRadius).attr(@appearance(index))

      # Similar but slightly larger pie piece used on hover
      if @options.hoverStroke
        piece.add @piece(startDegree, endDegree, normRadius + @options.hoverStroke).attr
          fill: @color(index)
          fillOpacity: @options.hoverOpacity
          class: 'snappy-pie-hover-path'

      # Pie piece value label
      if percentage >= @options.percentageCutoff
        text = if @options.percentage then "#{percentage}%" else value.value
        piece.add @snap.text(textPosition.x, textPosition.y, text).attr({style: 'text-anchor: middle'})

      # Draw textbox
      piece.add @drawTextbox(value.label, midDegree, normRadius) if value.label? && value.label? != ''

      @pieces.add piece

  drawTextbox: (text, degree, rad) ->
    textboxPosition = @degreeToCoords degree, rad
    textboxText = @snap.text(textboxPosition.x, textboxPosition.y, text).attr({style: 'alignment-baseline: hanging; text-anchor: middle'})
    bbox = textboxText.getBBox()

    dimensions =
      width:  bbox.width  + 2 * @options.textboxPadding
      height: bbox.height + 2 * @options.textboxPadding
      x: bbox.x - @options.textboxPadding
      y: bbox.y - @options.textboxPadding
    attrs =
      class: 'snappy-pie-textbox'

    if dimensions.x < 0
      attrs.transform = "translate(#{dimensions.x * -1})"
    # else if (dimensions.x + dimensions.width) > @options.width
    #   attrs.transform = "translate(#{( @options.width - dimensions.x - dimensions.width)})"

    box = @snap.rect(dimensions.x, dimensions.y, dimensions.width, dimensions.height)
    @snap.g(box, textboxText).attr(attrs)

  drawLegend: ->
    for value, index in @areas
      yPos =  index * (@options.legendLineheight + @options.legendPadding)
      colorBox = @snap.rect(@options.size, yPos, @options.legendLineheight, @options.legendLineheight).attr({fill: @color(index)})
      text = @snap.text(@options.size + @options.legendLineheight + @options.legendPadding, yPos + @options.legendLineheight / 2, value.label || value.value).attr({style: 'alignment-baseline: middle'})
      @legend.add @snap.g(colorBox, text).attr('data-value-index': index)

    @legend.attr({transform: "translate(0, #{(@options.size - @legend.getBBox().height) / 2 }})"})


  appearance: (index = 0) ->
    fillColor = @color(index)

    stroke:         fillColor
    fill:           fillColor
    strokeWidth:    @options.strokeWidth
    strokeOpacity:  @options.strokeOpacity
    class:          'snappy-pie-path'

  moveTo: (x,y, relative = false) ->
    [(if relative then 'm' else 'M'), x, y].join(' ')

  lineTo: (x,y, relative = false) ->
    [(if relative then 'l' else 'L'), x, y].join(' ')

  path: (commands = []) ->
    commands.push 'Z'
    @snap.path commands.join(' ')

  minMax: (min, max, value) ->
    Math.min(Math.max(value, min), max)

  degreeToCoords: (degree, radius = @radius) ->
    normDegree = Math.PI * (degree + 270) / 180
    {x: (@center + radius * Math.cos(normDegree)), y: (@center + radius * Math.sin(normDegree))}

  piece: (startDegree, endDegree, radius = @radius) ->
    startCoords = @degreeToCoords startDegree, radius
    endCoords = @degreeToCoords endDegree, radius

    arc = new SVGArc
      radiusX: radius
      radiusY: radius
      endX: endCoords.x
      endY: endCoords.y
      sweepFlag: 1
      largeArc: (if (endDegree - startDegree) > 180 then 1 else 0 )

    @path [
      @moveTo(@center, @center),
      @lineTo(startCoords.x, startCoords.y),
      arc.toString(),
      @lineTo(@center, @center)
    ]