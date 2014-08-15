class @SnappyDataSet
  constructor: (@options = {}) ->
    @dataSet = {}
    @

  addPoint: (index, value) ->
    val = Number(value)
    val.toFixed(@options.precision) if @options.precision?
    @dataSet[index] = val

    @min = val if (@min? && val < @min) || !@min?
    @max = val if (@max? && val > @max) || !@max?
