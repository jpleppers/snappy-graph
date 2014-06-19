$.numberToHex = (number, pad = false) ->
  hex = number.toString(16)
  if pad && hex.length == 1 then "0#{hex}" else hex

$.hexToNumber = (hex, pad = false) ->
  number = parseInt(hex, 16)
  if pad && number < 10 then "0#{number}" else number

$.mix = (c1, c2, percentage = 0) ->
  c1 = c1.replace '#', ''
  c2 = c2.replace '#', ''

  if percentage == 0
    '#' + c1
  else if percentage == 1
    '#' + c2
  else
    rgb1 = [
      $.hexToNumber(c1.substr(0,2)),
      $.hexToNumber(c1.substr(2,2)),
      $.hexToNumber(c1.substr(4,2))
    ]

    rgb2 = [
      $.hexToNumber(c2.substr(0,2)),
      $.hexToNumber(c2.substr(2,2)),
      $.hexToNumber(c2.substr(4,2))
    ]

    newColor = []
    for i in [0, 1, 2]
      normNumber = parseInt Math.min(rgb1[i], rgb2[i]) + Math.abs(rgb1[i] - rgb2[i]) * percentage
      newColor.push $.numberToHex(normNumber, true)

    '#' + newColor.join('')
