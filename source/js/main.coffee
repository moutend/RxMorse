$ = (elem) ->
  document.querySelectorAll elem

window.onload = () ->
  window.app =
    se: new Audio
    morse: new Morse
    settings:
      short_mute: 128
      short_beep: 128
      long_mute:  384
      long_beep:  256
      blank:      256

  _code  = ''
  _timer = null
  _input = null
  _push  = null
  _blur  = true

  keydown = (event) ->
    if _blur? and (event.keyCode is 32 or event.keyCode is 0)
      if _push is null
        window.app.se.playOsc()
        _push = setTimeout () ->
          window.app.se.stopOsc()
        , 1000
        _input = +new Date()
      if _timer isnt null
        clearTimeout _timer
        _timer = null
    null

  keyup = (event) ->
    if _blur? and (event.keyCode is 32 or event.keyCode is 0)
      window.app.se.stopOsc()
      if +new Date() - _input <  window.app.settings.short_beep
        _code += '.'
      else
        _code += '_'
      clearTimeout _push
      _push = null
      if _timer is null
        _timer = setTimeout () ->
          o = $('#output')[0]
          o.value += " #{_code}"
          encode()
          _timer = null
          _code = ''
        , window.app.settings.blank
    null

  decode = () ->
    i = $('#input')[0]
    o = $('#output')[0]
    o.value = window.app.morse
      .encode(i.value)
      .toString().replace /,/g, ' '

  encode = () ->
    i = $('#input')[0]
    o = $('#output')[0]
    i.value = window.app.morse
      .decode o.value.split(' ')

  beep = (milli_sec) ->
    return (resolve) ->
      window.app.se.playOsc()
      setTimeout () ->
        window.app.se.stopOsc()
        resolve()
      , milli_sec

  exec = (q) ->
    fire = () ->
      if q.length > 0
        eval(q.shift())(fire)
    fire()

  sleep = (milli_sec) ->
    return (resolve) ->
      setTimeout () ->
        resolve()
      , milli_sec

  play = () ->
    q = []
    for code in $('#output')[0].value.split ' '
      for char in code.split ''
        if char is '.'
          q.push beep(window.app.settings.short_beep)
        if char is '_'
          q.push beep(window.app.settings.long_beep)
        q.push sleep(window.app.settings.short_mute)
      q.push sleep(window.app.settings.long_mute)
    exec q

  focus = () ->
    _blur = null

  blur = () ->
    _blur = true

  btn_beep = $('#btn_beep')[0]
  if window.ontouchstart is null
    btn_beep.removeEventListener 'touchstart', keydown
    btn_beep.addEventListener    'touchstart', keydown
    btn_beep.removeEventListener 'touchend', keyup
    btn_beep.addEventListener    'touchend', keyup
  else
    btn_beep.removeEventListener 'mousedown', keydown
    btn_beep.addEventListener    'mousedown', keydown
    btn_beep.removeEventListener 'mouseup', keyup
    btn_beep.addEventListener    'mouseup', keyup

  btn_play = $('#btn_play')[0]
  if window.ontouchstart is null
    btn_play.removeEventListener 'touchstart', play
    btn_play.addEventListener    'touchstart', play
  else
    btn_play.removeEventListener 'mousedown', play
    btn_play.addEventListener    'mousedown', play

  body = $('body')[0]
  body.removeEventListener 'keydown', keydown
  body.addEventListener    'keydown', keydown
  body.removeEventListener 'keyup',   keyup
  body.addEventListener    'keyup',   keyup

  input = $('#input')[0]
  input.removeEventListener 'input', decode
  input.addEventListener    'input', decode
  input.removeEventListener 'focus', focus
  input.addEventListener    'focus', focus
  input.removeEventListener 'blur',   blur
  input.addEventListener    'blur',   blur

  output = $('#output')[0]
  output.removeEventListener 'input', encode
  output.addEventListener    'input', encode
  output.removeEventListener 'focus', focus
  output.addEventListener    'focus', focus
  output.removeEventListener 'blur',  blur
  output.addEventListener    'blur',  blur

