$ ->
  $('[data-toggle=snappy-pie]').each ->
    $this = $(this)
    $this.data 'snappy-pie', new SnappyPie($this)

  $('[data-toggle=snappy-graph]').each ->
    $this = $(this)
    $this.data 'snappy-graph', new SnappyGraph($this)