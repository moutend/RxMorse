class Audio
  _audioContext = null
  _osc          = null

  constructor: () ->
    @freq = 880
    if AudioContext?
      _audioContext = new AudioContext
      return
    if webkitAudioContext?
      _audioContext = new webkitAudioContext

  playOsc: () ->
    _osc = _audioContext.createOscillator()
    _osc.frequency.value = @freq
    _osc.connect _audioContext.destination
    _osc.start()

  stopOsc: () ->
    _osc.stop()
