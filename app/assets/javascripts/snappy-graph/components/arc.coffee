class @SVGArc
  constructor: (@options) ->
    @sd 'radiusX', 10
    @sd 'radiusY', 10
    @sd 'xAxisRotation', 0
    @sd 'largeArc', 0
    @sd 'sweepFlag', 0
    @sd 'endX', 0
    @sd 'endY', 0

  # Set Defaults
  sd: (key, value) ->
    @options[key] = value if !@options[key]

  toString: ->
     [  'A',
        @options.radiusX,
        @options.radiusY,
        @options.xAxisRotation,
        @options.largeArc,
        @options.sweepFlag,
        @options.endX,
        @options.endY
     ].join(' ')