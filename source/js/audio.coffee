class Audio
  _ttl = 3000
  _format = null
  _pending = []
  _audioContext = null
  _audioBuffers = []
  _soundURL = ""
  _audioTagID = null
  _audioTagNameToElement = {}
  _osc = null

  constructor: () ->
    _format = 'not found'
    if navigator.userAgent.indexOf 'Firefox'?
      _format = 'AudioTag'
    if AudioContext?
      _format = 'AudioContext'
    if webkitAudioContext?
      _format = 'webkitAudioContext'

    switch _format
      when 'AudioContext', 'webkitAudioContext'
        @load = @loadAudioContext
        @play = @playAudioContext
        if webkitAudioContext?
          _audioContext = new webkitAudioContext()
          break
        if AudioContext?
          _audioContext = new AudioContext()
      when 'AudioTag'
        @load = @loadAudioTag
        @play = @playAudioTag

  getSingleURL: (urls) ->
    if typeof urls is "string"
      return urls
    urls[0]

  getTagFromURL: (url, tag) ->
    if tag?
      return tag
    @getSingleURL url

  playAudioTag: (tag) ->
    modelId = _audioTagNameToElement[tag]
    cloneId = "clone-audio-track-#{_audioTagID++}"
    pool = document.querySelector '#audio-pool'
    elem = document.querySelector "##{modelId}"
    cloneElem = elem.cloneNode true
    cloneElem.setAttribute 'id', cloneId
    pool.appendChild cloneElem
    cloneElem.addEventListener 'canplay', () ->
      cloneElem.play()
    cloneElem.addEventListener 'ended', () ->
      cloneElem.remove()

    setTimeout () ->
      if cloneElem?
        cloneElem.remove()
    , _ttl

  loadAudioTag: (urls, tag) ->
    createElem = (tag_name, attrs) ->
      node = document.createElement tag_name
      for key, value of attrs
        node.setAttribute key, value
      node

    guessFileType = (url) ->
      type = url.split '.'
      type[type.length - 1].toLowerCase()

    audioPool = document.querySelector '#audio-pool'
    if audioPool is null
      audioPool = createElem 'div', id: 'audio-pool'
      body = document.querySelector 'body'
      body.appendChild audioPool

    id = "audio-track-#{_audioTagID++}"
    _audioTagNameToElement[tag] = id

    audioElem = createElem 'audio', {id: id, preload: 'auto'}
    attr =
      type: "audio/#{guessFileType urls[0]}"
      src:  _soundURL + urls[0]
    sourceElem = createElem 'source', attr
    audioElem.appendChild sourceElem
    audioPool.appendChild audioElem
    console.log audioElem

  playAudioContext: (tag) ->
    try
      buffer = _audioBuffers[tag]
      if buffer is undefined
        _pending[tag] = true
        return null
      context = _audioContext
      source = context.createBufferSource()
      source.buffer = buffer
      source.connect context.destination
      if source.noteOn?
        source.noteOn(0)
        return null
      source.start 0
    catch e

  loadAudioContext: (urls, tag) ->
    try
      self = this
      url = @getSingleURL urls
      tag = @getTagFromURL urls, tag
      request = new XMLHttpRequest()
      request.open 'GET', url, true
      request.responseType = 'arraybuffer'
      request.onload = () ->
        _audioContext.decodeAudioData request.response, (buffer) ->
          _audioBuffers[tag] = buffer
          if _pending[tag]
            self.playAudioContext tag
        , () ->
          throw new Error 'Failed to decode.'
      request.send()
    catch e

  playOsc: () ->
    _osc = _audioContext.createOscillator()
    _osc.frequency.value = 880
    _osc.connect _audioContext.destination
    _osc.start()
    null

  stopOsc: () ->
    _osc.stop()
    null
