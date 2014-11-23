class Audio
  _audioContext = null
  _osc          = null
  _q            = []
  @obj          = null

  _$ = (el) ->
    document.querySelectorAll el

  playOsc: () ->
    try
      _gain = _audioContext.createGain()
      _osc = _audioContext.createOscillator()
      _gain.gain.value = @obj.gain
      _osc.frequency.value = @obj.freq
      _osc.connect _gain
      _gain.connect _audioContext.destination
      _osc.start 0
    catch e
      alert "Audio Error: #{e}"

  stopOsc: () ->
    try
      _osc.stop 0
    catch e
      alert "Audio Error: #{e}"

  freq: () =>
    @obj.freq = parseInt _$('#input_freq')[0].value

  gain: () =>
    @obj.gain = parseFloat _$('#input_gain')[0].value

  bpm: () =>
    c = 1 / (parseInt(_$('#input_bpm')[0].value) / 60) * 1000
    @obj.short_mute = 1 / 4 * c
    @obj.short_beep = 1 / 4 * c
    @obj.long_mute  = 3 / 4 * c
    @obj.long_beep  = 3 / 4 * c
    @obj.blank      = 2 / 3 * c

  beep: (milli_sec) =>
    return (resolve) =>
      @playOsc()
      setTimeout () =>
        @stopOsc()
        resolve()
      , milli_sec

  sleep = (milli_sec) ->
    return (resolve) ->
      setTimeout () ->
        resolve()
      , milli_sec

  exec = (q) ->
    fire = () ->
      if q.length > 0
        eval(q.shift())(fire)
    fire()

  play: () =>
    return if _q.length isnt 0
    for code in _$('#input_code')[0].value.split ' '
      for char in code.split ''
        if char is '.'
          _q.push @beep(@obj.short_beep)
        if char is '_'
          _q.push @beep(@obj.long_beep)
        _q.push sleep(@obj.short_mute)
      _q.push sleep(@obj.long_mute)
    exec _q

  constructor: (obj) ->
    @obj = obj
    @bpm()

    if AudioContext?
      _audioContext = new AudioContext
      return

    if webkitAudioContext?
      _audioContext = new webkitAudioContext
      return

    alert 'You need the Browser support Web Audio.'

