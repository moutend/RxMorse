window.onload = () ->
  _$ = (el) ->
    document.querySelectorAll el

  encode = () ->
    i = _$('#input_str')[0]
    o = _$('#input_code')[0]
    o.value = window.app.morse
      .encode(i.value.toLowerCase())
      .toString().replace /,/g, ' '
    o.value += ' '
    window.app.codes = o.value.split ' '

  decode = () ->
    i = _$('#input_str')[0]
    o = _$('#input_code')[0]
    dot  = window.app.key.dot()
      .replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
    dash = window.app.key.dash()
      .replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");

    window.app.codes = o.value
      .replace(new RegExp(dot, 'g'), '.')
      .replace(new RegExp(dash, 'g'), '_')
      .split(' ')

    i.value = window.app.morse
      .decode window.app.codes

  clear = () ->
    _$('#input_str')[0].value  = ''
    _$('#input_code')[0].value = ''

  open_settings = () ->
    _$('#settings')[0].style.display = 'block'
    _$('#home')[0].style.display = 'none'

  close_settings = () ->
    _$('#settings')[0].style.display = 'none'
    _$('#home')[0].style.display = 'block'

  reset_params = () ->
    _$('#input_gain')[0].value = window.app.se.obj.gain = 0.5
    _$('#input_freq')[0].value = window.app.se.obj.freq = 880
    _$('#input_bpm')[0].value  = window.app.se.obj.bpm  = 192
    window.app.se.bpm()
    _$('#input_dot')[0].value  = window.app.key.dot  = '.'
    _$('#input_dash')[0].value = window.app.key.dash = '_'

  window.app =
    blur: true
    codes: []
    morse: new Morse
    se: new Audio obj =
      freq: 880
      gain: 0.5
      bpm:  180
    key: new Key obj =
      beep_key: ['body']
      beep_btn: ['#btn_beep']
      code:     '#input_code'
      str:      '#input_str'
      hook:     decode
      dot:      '.'
      dash:     '_'

  inputs =
    '#input_gain':  window.app.se.gain
    '#input_freq':  window.app.se.freq
    '#input_bpm':   window.app.se.bpm
    '#input_dot':   window.app.key.dot
    '#input_dash':  window.app.key.dash
    '#input_str':   encode
    '#input_code':  decode

  focus = () -> window.app.blur = null
  blur  = () -> window.app.blur = true
  input = (el, fn) ->
    return () ->
      fn _$(el)[0].value

  for key, value of inputs
    e = _$(key)[0]
    e.removeEventListener 'input', input(key, value)
    e.addEventListener    'input', input(key, value)
    e.removeEventListener 'focus', focus
    e.addEventListener    'focus', focus
    e.removeEventListener 'blur',  blur
    e.addEventListener    'blur',  blur

  btns =
    '#btn_cog':   open_settings
    '#btn_play':  window.app.se.play
    '#btn_close': close_settings
    '#btn_clear': clear
    '#btn_reset': reset_params

  for key, value of btns
    el = _$(key)[0]
    if window.ontouchstart is null
      el.removeEventListener 'touchstart', value
      el.addEventListener    'touchstart', value
    else
      el.removeEventListener 'mousedown', value
      el.addEventListener 'mousedown', value

