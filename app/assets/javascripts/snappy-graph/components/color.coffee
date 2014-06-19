# Color object for mixing colors

class @Color
  constructor: (@options={}) ->
    @fromHexString(@options['hex']) if @options['hex']?

    for key in 'cmykrgba'.split('')
      @[key] = @options[key] if @options[key]?

    @a = 1 unless @a?

  hexToNumber: (hex, pad = false) ->
    number = parseInt(hex, 16)
    if pad && number < 10 then "0#{number}" else number

  fromHexString: (hexString) ->
    hexString = hexString.replace '#', ''

    @r = $.hexToNumber(hexString.substr(0,2))
    @g = $.hexToNumber(hexString.substr(2,2))
    @b = $.hexToNumber(hexString.substr(4,2))

  toRGB: (recalculate = false) ->
    @CMYKtoRGB() if !(@r? && @g? && @b?) || recalculate
    {r: @r, g: @g, b: @b}

  toCMYK: (recalculate = false) ->
    @RGBtoCMYK() if !(@c? && @m? && @y? && @k?) || recalculate
    {c: @c, m: @m, y: @y, k: @k}

  toRGBstring: ->
    @toRGB()
    "rgb(#{@r}, #{@g}, #{@b})"

  toRGBAstring: ->
    @toRGB()
    "rgba(#{@r}, #{@g}, #{@b}, #{@a})"

  toHexString: ->
    @toRGB() if !@r? || !@g? || !@b?
    ['#', @hexToNumber(@r, true), @hexToNumber(@g, true), @hexToNumber(@b, true)]

  CMYKtoRGB: () ->
    cmyk = 'cmyk'.split('')
    rgb = 'rgb'.split('')

    cmykComp = []
    for i in [0..3]
      cmykComp[i] = @[cmyk[i]] / 100

    for i in [0..2]
      comp = 1 - Math.min 1, cmykComp[i] * ( 1 - cmykComp[3] ) + cmykComp[3]
      @[rgb[i]] = Math.round comp * 255

  # Simple RGB to CMYK conversion. Conversion isnt 100% spot on but should be sufficient for color mixing
  RGBtoCMYK: () ->
    cmyk = 'cmyk'.split('')
    rgb = 'rgb'.split('')

    rgbComp = []
    for i in [0..2]
      rgbComp[i] = @[rgb[i]] / 255

    # Key color first
    cmykComp = []
    cmykComp[3] = Math.min( 1 - rgbComp[0], 1 - rgbComp[1], 1 - rgbComp[2] )
    for i in [0..2]
      cmykComp[i] = ( 1 - rgbComp[i] - cmykComp[3] ) / ( 1 - cmykComp[3] )

    for i in [0..3]
      @[cmyk[i]] = Math.round cmykComp[i] * 100

  mixWith: (otherColor, percentage) ->
    percentage = percentage / 100 if percentage > 1
    @toCMYK()
    otherColor.toCMYK()

    if percentage == 0
      @
    else if percentage == 1
      otherColor
    else
      cmyk = 'cmyk'.split('')
      components = []

      for i in [0..3]
        key = cmyk[i]
        baseComp = Math.min @[key], otherColor[key]
        multiplier = if @[key] > otherColor[key] then (1 - percentage) else percentage
        components[key] = baseComp + Math.abs(@[key] - otherColor[key]) * multiplier

      new Color({c: components['c'], m: components['m'], y: components['y'], k: components['k']})

$ ->
  $('.color-box-wrapper').each ->
    $this = $(this)

    color1 = new Color { hex: $this.data('color-from')}
    color2 = new Color { hex: $this.data('color-to')}
    steps = $this.data('steps') - 1

    for i in [0..steps]
      color = color1.mixWith color2, i / steps
      $this.append "<div class='color-box' style='background-color: #{color.toRGBstring()}'></div>"
