class Key
  _timer  = null
  _date   = null
  _push   = null
  _isBlur = true
  _code   = ''
  _str    = ''
  _$      = (e) -> document.querySelectorAll e
  _hook   = () -> null
  _blur  = () -> _isBlur = true
  _focus = () -> _isBlur = null

  constructor: (obj) ->
    _hook = obj.hook
    _code = obj.code
    _str  = obj.str

    for e in [_code, _str]
      e = _$(obj.str)[0]
      e.removeEventListener 'blur',  _blur
      e.addEventListener    'blur',  _blur
      e.removeEventListener 'focus', _focus
      e.addEventListener    'focus', _focus

    for el in obj.beep_key
      e = _$(el)[0]
      e.removeEventListener 'keydown', @down
      e.addEventListener    'keydown', @down
      e.removeEventListener 'keyup',   @up
      e.addEventListener    'keyup',   @up

    for el in obj.beep_btn
      e = _$(el)[0]
      if window.ontouchstart is null
        e.removeEventListener 'touchstart', @down
        e.addEventListener    'touchstart', @down
        e.removeEventListener 'touchend',   @up
        e.addEventListener    'touchend',   @up
      else
        e.removeEventListener 'mousedown', @down
        e.addEventListener    'mousedown', @down
        e.removeEventListener 'mouseup',   @up
        e.addEventListener    'mouseup',   @up

  down: (e) ->
    if _isBlur? and (e.keyCode is 32 or e.keyCode is 0)
      if _push is null
        window.app.se.playOsc()
        _push = setTimeout () ->
          window.app.se.stopOsc()
        , 1000
        _date = +new Date()
      if _timer isnt null
        clearTimeout _timer
        _timer = null
    null

  up: (e) ->
    if _isBlur? and (e.keyCode is 32 or e.keyCode is 0)
      window.app.se.stopOsc()
      if +new Date() - _date <  window.app.se.obj.short_beep * 1.6
        _$(_code)[0].value += '.'
      else
        _$(_code)[0].value += '_'
      clearTimeout _push
      _push = null
      if _timer is null
        _timer = setTimeout () ->
          _hook?()
          _$(_code)[0].value += ' '
          _timer = null
        , window.app.se.obj.blank
    null

