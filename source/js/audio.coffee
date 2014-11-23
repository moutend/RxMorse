class Audio
  _audioContext = null
  _osc          = null
  _q            = null
  _$ = (el) ->
    document.querySelectorAll el

  obj: null

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

  freq: (val) =>
    return @obj.freq if val is undefined
    @obj.freq = parseInt val

  gain: (val) =>
    return @obj.gain if val is undefined
    @obj.gain = parseFloat val

  bpm: (val) =>
    return @obj.bpm if val is undefined
    co = 1 / (parseInt(val) / 60) * 1000
    @obj.short_mute = 1 / 4 * co
    @obj.short_beep = 1 / 4 * co
    @obj.long_mute  = 3 / 4 * co
    @obj.long_beep  = 3 / 4 * co
    @obj.blank      = 2 / 3 * co
    val

  s_beep: () =>
    return (resolve) =>
      @playOsc()
      setTimeout () =>
        @stopOsc()
        resolve()
      , @obj.short_beep

  l_beep: () =>
    return (resolve) =>
      @playOsc()
      setTimeout () =>
        @stopOsc()
        resolve()
      , @obj.long_beep


  sleep = (milli_sec) ->
    return (resolve) ->
      setTimeout () ->
        resolve()
      , milli_sec

  exec = (q) ->
    fire = () ->
      if q.length > 0
        eval(q.shift())(fire)
      else
        _q = null
    fire()

  play: () =>
    return null if _q?
    _q = []
    for code in window.app.codes
      for char in code.split ''
        if char is '.'
          _q.push @s_beep()
        if char is '_'
          _q.push @l_beep()
        _q.push sleep(@obj.short_mute)
      _q.push sleep(@obj.long_mute)
    exec _q

  constructor: (obj) ->
    @obj = obj
    @bpm(@obj.bpm)

    if AudioContext?
      _audioContext = new AudioContext
      return

    if webkitAudioContext?
      _audioContext = new webkitAudioContext
      return

    alert 'You need the Browser support Web Audio.'

