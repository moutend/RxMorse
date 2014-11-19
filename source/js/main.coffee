$ = (elem) ->
  document.querySelectorAll elem

window.onload = () ->
  _timer = null
  _input = null
  _short = 200
  _code  = ''
  _push  = null

  _keydown = (event) ->
    if event.keyCode is 32 or event.keyCode is 0
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

  _keyup = (event) ->
    if event.keyCode is 32 or event.keyCode is 0
      window.app.se.stopOsc()
      if +new Date() - _input <  _short
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
        , 320
    null

  decode = () ->
    i = $('#input')[0]
    o = $('#output')[0]
    o.value = window.app.morse
      .encode(i.value)
      .toString().replace /,/g, ' '
    null

  encode = () ->
    i = $('#input')[0]
    o = $('#output')[0]
    i.value = window.app.morse
      .decode o.value.split(' ')
    null

  beep = $('#beep')[0]
  if window.ontouchstart is null
    beep.removeEventListener 'touchstart', _keydown
    beep.addEventListener    'touchstart', _keydown
    beep.removeEventListener 'touchend', _keyup
    beep.addEventListener    'touchend', _keyup
  else
    beep.removeEventListener 'mousedown', _keydown
    beep.addEventListener    'mousedown', _keydown
    beep.removeEventListener 'mouseup', _keyup
    beep.addEventListener    'mouseup', _keyup

  body = $('body')[0]
  body.removeEventListener 'keydown', _keydown
  body.addEventListener    'keydown', _keydown
  body.removeEventListener 'keyup',   _keyup
  body.addEventListener    'keyup',   _keyup

  input = $('#input')[0]
  input.removeEventListener 'input', decode
  input.addEventListener    'input', decode
  output = $('#output')[0]
  output.removeEventListener 'input', encode
  output.addEventListener    'input', encode
  null

  window.app =
    morse: new Morse
    se: new Audio

