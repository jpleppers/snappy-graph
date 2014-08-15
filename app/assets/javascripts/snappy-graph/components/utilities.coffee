$.numberToHex = (number, pad = false) ->
  hex = number.toString(16)
  if pad && hex.length == 1 then "0#{hex}" else hex

$.hexToNumber = (hex, pad = false) ->
  number = parseInt(hex, 16)
  if pad && number < 10 then "0#{number}" else number

$.minMax = (min, max, value) ->
  Math.min(Math.max(value, min), max)