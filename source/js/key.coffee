class Key
  _prefix    = '.btn-'
  _suffix    = ''
  _input     = 0
  _fn        = {}

  _E = (str) ->
    window.document.querySelectorAll str

  _focus = () ->
    _input += 1

  _blur= () ->
    _input -= 1

  _keymap = (event) ->
    char = event.keyCode.toString()
    console.log char
    if (event.metaKey is true and
    event.ctrlKey is false or
    event.metaKey is false and
    event.ctrlKey is true)
      if char is 'r'
        event.preventDefault?()

    keys = []
    keys.push key for key of _fn

    for key in keys
      if char is key
        _fn[key]?(event) if _input is 0
        return null
    null

  _reset = () ->
    for key of _fn
      list = _E "#{_prefix}#{key}#{_suffix}"
      return null if list.length is 0
      if window.ontouchstart is null
        for e in list
          e.removeEventListener 'touchstart', _fn[key], true
      else
        for e in list
          e.removeEventListener 'mousedown', _fn[key], true
    null

  reset: () ->
    _reset()

  load: (obj) ->
    console.log 'hoge'
    button = (key) ->
      list = _E "#{_prefix}#{key}#{_suffix}"
      if window.ontouchstart is null
        for e in list
          e.addEventListener    'touchstart', _fn[key], true
      else
        for e in list
          e.addEventListener    'mousedown', _fn[key], true
      null

    textarea = (elem) ->
      list  = _E elem
      return null if list is null

      for e in list
        e.removeEventListener 'focus', _focus
        e.addEventListener    'focus', _focus
        e.removeEventListener 'blur',  _blur
        e.addEventListener    'blur',  _blur
      null

    if obj.input?
      textarea elem for elem in obj.input

    _reset()
    _fn = obj.keys
    if _fn?
      button key for key of obj.keys

    body = _E('body')[0]
    body.removeEventListener 'keydown', _keymap
    body.addEventListener    'keydown', _keymap
    null

