class @SnappyGraph
  sets: []
  indices: []
  labels: []
  title: ''

  constructor: (@element, options = {}) ->
    if $('tr', @element).length > 0
      $('tr', @element).each (rowIndex, row) =>

        $('td, th', row).each (cellIndex, cell) =>
          $cell = $(cell)

          if rowIndex == 0 && cellIndex == 0
            @title = $cell.html()
          else if rowIndex == 0
            @labels[cellIndex - 1] = $cell.html()
          else if cellIndex == 0
            @indices[rowIndex] = Number($cell.html())
          else
            @checkDataSet(cellIndex - 1)
            @sets[cellIndex - 1].addPoint @indices[rowIndex], $cell.html()

      console.log @min()
      console.log @max()

  checkDataSet: (index) ->
    unless @sets[index]?
      @sets[index] = new SnappyDataSet()

  min: ->
    for set in @sets
      min = set.min if set.min < min || !min?
    min

  max: ->
    for set in @sets
      max = set.max if set.max > max || !max?
    max




