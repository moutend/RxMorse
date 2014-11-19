class Cards
  constructor: () ->
    _buffer = []
    _num = 0
    _len = 0

    @add = (cards_array) ->
      for card in cards_array
        if !card.front?
          card.front = ''
        if !card.back?
          card.back = ''
        if !card.date?
          card.date = +mew Date()
        if !card.score?
          card.back = 0
        if !card.period?
          card.period= 0
        _buffer[_len] = card
        _len += 1
      null

    @create = (opt_cards_array) ->
      if opt_cards_array?
        _len = opt_cards_array.length
        _buffer = opt_cards_array
        for card, index in _buffer
          _buffer[index] = card
        return null

      card =
        front:  ''
        back:   ''
        date:   +new Date()
        score:  0
        period: 0

      _len += 1
      _buffer.push card
      null

    @delete = () ->
      buf_l = _buffer.slice 0, _num
      buf_r = _buffer.slice _num, _buffer.length
      buf_r.shift()
      Array.prototype.push.apply buf_l, buf_r
      _buffer = buf_l
      _len = _buffer.length
      if _num is _len and _num > 0
        _num -= 1
      null

    @first = () ->
      _num = 0

    @last = () ->
      _num = _buffer.length - 1

    @next = () ->
      if _num < _len - 1
        _num += 1

    @prev = () ->
      if _num > 0
        _num -= 1

    @getAll = () ->
      _buffer

    @getNext = () ->
      if _buffer[_num + 1] is null
        return null
      if _buffer[_num + 1]?
        return _buffer[_num + 1]
      undefined

    @getCard = (n) ->
      _buffer[n]

    @getCurrent = () ->
      _buffer[_num]

    @setCurrent = (card) ->
      if card.front?
        _buffer[_num].front = card.front
      if card.back?
        _buffer[_num].back = card.back
      if card.date?
        _buffer[_num].date = card.date
      if card.period?
        _buffer[_num].period = card.period
      if card.score?
        _buffer[_num].score = card.score

    @getLen = () ->
      _buffer.length

    @getNum = () ->
      _num

