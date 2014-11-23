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

  decode = () ->
    i = _$('#input_str')[0]
    o = _$('#input_code')[0]
    i.value = window.app.morse
      .decode o.value.split(' ')

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
    _$('#input_gain')[0].value = 0.5
    _$('#input_freq')[0].value = 880
    _$('#input_bpm')[0].value  = 192
    _$('#input_dot')[0].value  = 192
    _$('#input_dash')[0].value = 192

  window.app =
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

  inputs =
    '#input_gain':  window.app.se.gain
    '#input_freq':  window.app.se.freq
    '#input_bpm':   window.app.se.bpm
    '#input_str':   encode
    '#input_code':  decode

  for key, value of inputs
    el = _$(key)[0]
    el.removeEventListener 'input', value
    el.addEventListener    'input', value

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

