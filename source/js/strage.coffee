class Strage
  _buffer = null

  save: (cards, callback) ->
    if app.client is null
      callback()
      return null

    data =
      english:
        cards: cards

    data_str = JSON.stringify data
    app.client.writeFile "#{app.tagname}.huda", data_str, (error) ->
      if error?
        callback error
      callback null
    null

  load: (callback) ->
    DROPBOX_APP_KEY = '6j70j9g5obmkmpq'
    if app.client is null
      app.client = new Dropbox.Client key: DROPBOX_APP_KEY
      app.client.authenticate (error) ->
        if error?
          callback '認証が失敗しました。'
          return null
    app.client.readFile "#{app.tagname}.huda", {}, (error, file, stat) ->
      if error?
        callback []
        return null

      try
        data = JSON.parse file
        callback data['english'].cards
      catch error
        callback 'ファイルが破損しています。'
    null

  loadLocal: () ->
    local = JSON.parse localStorage.getItem 'deck'
    if local is null
      return null
    cards = local['english'].cards
    cards

  saveLocal: (cards) ->
    data =
      english:
        cards: cards
    str = JSON.stringify data
    localStorage.setItem 'deck', str
    null

#  store: (res) ->
#    save_local = (tag_name) ->
#      local = JSON.parse localStorage.getItem "deck"
#      if res.buf?
#        for card, key in res.buf
#          res.buf[key].back = card.back.replace /\n/g, '<br />'
#
#        if local is null
#          local = {}
#          local[tag_name] =
#            description: ''
#            cards: []
#        if res.mode is 'add'
#          for card in res.buf
#            local[tag_name].cards.push card
#        else
#          local[tag_name].cards = res.buf
#
#      if res.forgot?
#        for index, card of res.forgot
#          i = get_card {cards: local[tag_name].cards, front: card.front}
#          if res.cards[i].score > 0
#            local[tag_name].cards[i].score -= 1
#
#      if res.right?
#        for value, index in res.right
#          obj =
#            cards: local[tag_name].cards
#            front: value.front
#          i = get_card obj
#          if i isnt null
#            local[tag_name].cards[i].score += 1
#            local[tag_name].cards[i].date = +new Date()
#
#      if res.cards?
#        for value, index in res.cards
#          if value?
#            obj =
#              cards: local[tag_name].cards
#              front: value.front
#            i = get_card obj
#            if i isnt null
#              local[tag_name].cards[i].period += res.cards[i].period
#              local[tag_name].cards[i].front = res.cards[i].front.replace /\n/g, '<br />'
#              local[tag_name].cards[i].back = res.cards[i].back.replace /\n/g, '<br />'
#
#      localStorage.setItem "deck", JSON.stringify local
#      null
#
