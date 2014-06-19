class @SnappyPie
  constructor: (@element, @options = {}) ->
    window.snappyPies = 1 unless window.snappyPies
    @pieId = "snappy-pie-#{window.snappyPies}"
    window.snappyPies++

    defaults =
      size:             400
      sort:             true
      strokeWidth:      1
      strokeOpacity:    0.5
      animate:          false
      animationOffset:  0.1
      animationStart:   0.6
      duration:         800
      circleOffset:     40
      background:       'whitesmoke'
      theme:            'bluegreen'
      colors:           null
      colorsSeparator:  ','
      colorsCycle:       false

    for key, value of defaults
      unless @options[key]
        if @element.data(key)?
          @options[key] = @element.data(key)
        else
          @options[key] = value

    @pieces = []
    @colors =
      bluegreen:  ['0B486B', 'CFF09E']
      sun:        ['f91700', 'ffb400']
      bluered:    ['ff0000', '12476e']
      contrast:   ['ff0000', '00ff2a']

    if @options.colors?
      @options.colors = @options.colors.split(@options.colorsSeparator)
    else
      @options.colors = []

    tagStyle = ["width:#{@options.size}px", "height: #{@options.size}px", "line-height: #{@options.size}px"]


    @center = @options.size / 2
    @radius = @options.size / 2 - @options.circleOffset - @options.strokeWidth

    @svgContainer = $("<svg id='#{@pieId}' class='snappy-pie' style='#{tagStyle.join('; ')}' viewBox='0 0 #{@options.size} #{@options.size}'>")
    @element.after @svgContainer
    @snap = Snap("##{@pieId}")
    @background = @snap.rect(0,0 , @options.size, @options.size).attr({fill: @options.background}) if @options.background?

    values = []
    $('li', @element).each (-> values.push parseInt($(this).html()))
    @createAreas values
    @draw()
    @element.hide()

  createAreas: (values) ->
    total = 0
    values.sort((a,b)-> b - a) if @options.sort
    total += value for value in values
    @values = []

    previous = 0
    for value in values
      start = previous
      end = previous + (value * 360 / total)
      @values.push {start: start, end: end}
      previous = end

  color: (index) ->
    if @options.colors.length > 0
      index = index % @options.colors.length if @options.colorsCycle
      @options.colors[index]
    else
      @colorStart = new Color {hex: @colors[@options.theme][0]}
      @colorEnd = new Color {hex: @colors[@options.theme][1]}
      newColor = @colorStart.mixWith @colorEnd, index / (@values.length - 1)
      newColor.toRGBstring()

  draw: ->
    if @options.animate
      offset = @radius * @options.animationOffset
      Snap.animate @radius * @options.animationStart, (@radius + @values.length * offset), ((radius) => @drawPieces(radius, offset)), @options.duration, mina.easein
    else
      @drawPieces()

  drawPieces: (radius, offset = 0) ->
    radius = @radius unless radius?

    $('.snappy-pie-path', @svgContainer).remove()
    for value, index in @values
      normRadius = Math.min(Math.max(radius - (index * offset), 0), @radius)
      @pieces[index] = @piece(value.start, value.end, normRadius).attr(@appearance(index))

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

  degreeToCoords: (degree, radius = @radius) ->
    normDegree = Math.PI * (degree + 270) / 180
    {x: (@center + radius * Math.cos(normDegree)).toFixed(2), y: (@center + radius * Math.sin(normDegree)).toFixed(2)}

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



$ ->
  $('[data-toggle=snappy-pie]').each ->
    $this = $(this)
    $this.data 'snappy-pie', new SnappyPie($this)