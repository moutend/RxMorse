class Speech
  constructor: (message) ->
    return null
    message = message + '...' + message.split ''
    ssu = new SpeechSynthesisUtterance message
    window.speechSynthesis.speak ssu

class Screen
  _current = 'Ready'
  _transition = 0

  transition: (state_name) ->
    getElem = (screen_name) ->
      elem = null
      switch screen_name
        when 'Ready'
          elem = $ '#ready'
        when 'Done'
          elem = $ '#done'
        when 'Settings'
          elem = $ '#settings'
        when 'Error'
          elem = $ '#error'
        when 'Success'
          elem = $ '#success'
        when 'Loading'
          elem = $ '#loading'
        when 'Saving'
          elem = $ '#saving'
        when 'home'
          elem = $ '#home'
        when 'edit'
          elem = $ '#chose-edit-type'
        when 'ChoseTag'
          elem = $ '#chose-tag'
        when 'ChoseTagSaving'
          elem = $ '#chose-tag-saving'
        when 'ApplyTag'
          elem = $ '#apply-tag'
        when 'Loading'
          elem = $ '#chose-edit-type'
        when 'TestResult'
          elem = $ '#test-result'
        when 'TestLearned'
          elem = $ '#test-learned'
        when 'TestNotfound'
          elem = $ '#test-notfound'
        when 'TestQuestion'
          elem = $ '#test-question'
        when 'TestAnswer'
          elem = $ '#test-answer'
        when 'RegisterCardsByHand'
          elem = $ '#add-cards-manually'
        when 'RegisterCardsByWords'
          elem = $ '#add-card-from-text'
        when 'RegisterCardsByWordsInput'
          elem = $ '#register-cards-by-words-create'
        when 'RegisterCardsByWordsNotfound'
          elem = $ '#register-cards-by-words-notfound'
        when 'ImportCards'
          elem = $ '#cards-import'
        when 'ImportError'
          elem = $ '#cards-import-error'
        when 'ImportFinished'
          elem = $ '#cards-import-finished'
        when 'ExportCards'
          elem = $ '#cards-export'
      elem

    setScreen = (to) ->
      from_el = getElem _current
      to_el = getElem to
      if from_el? and to_el?
        from_el
          .hide()
        to_el
          .fadeIn()
        _current = to

    setScreen state_name

class Ready
  _vm = null
  _summary =
    message: 'ストレージを選択してください'
    status: '続けるには、ストレージを選択する必要があります。'

  constructor: () ->
    show_settings = () ->
      return null
      go_back = () ->
        app.screen.transition 'home'
        app.se.play 'click'
        null

      app.screen.transition 'Settings'
      app.se.play 'click'
      app.key.load obj =
        keys:
          h: go_back

    loadCard = () ->
      strage = new Strage
      strage.load (cards_array) ->
        cards = new Cards
        if cards_array.length > 0
          cards.create cards_array
          app.cards = cards
        else
          app.cards = 'not found'

        setTimeout () ->
         app.se.play 'ok'
        , 0
        app.screen.transition 'home'
        new Home
      null

    auth_dropbox = () ->
      _summary.strage = 'DropBox'
      _summary.message = 'DropBoxに接続しています。'

      if app.cards is 'pending'
        DROPBOX_APP_KEY = '6j70j9g5obmkmpq'
        app.strage = 'Dropbox'
        setTimeout () ->
          app.client = new Dropbox.Client key: DROPBOX_APP_KEY
          app.client.authenticate (error) ->
            if error?
              _summary.message = '認証に失敗しました'
              _summary.status = 'もう一度ストレージを選択してください。'
              app.strage = 'localStrage'
              return null
            app.strage = 'DropBox'
            loadCard()
        , 1000

    offline = () ->
      app.se.play 'ok'
      app.cards = 'not found'
      app.screen.transition 'home'
      new Home
      null

    check = () ->
      if localStorage.getItem 'tagname'
        app.tagname = localStorage.getItem 'tagname'
      strage = localStorage.getItem 'strage'
      if strage is 'DropBox'
        auth_dropbox()
      null

    $ '#dropbox'
      .click () ->
        auth_dropbox()

    $ '#offline'
      .click () ->
        offline()

    app.status = message: 'ストレージを選択'
    vue_status =
      el: '#status'
      data:
        status: app.status
    new Vue vue_status

    vue_obj =
      el: '#ready'
      data:
        summary: _summary

    _vm = new Vue vue_obj
    check()

class ChoseTag
  _vm = null
  _tag =
    name: ''

  constructor: () ->
    done = () ->
      app.status.message = 'タグを変更しました'
      vue_obj =
        el: '#apply-tag'
        data:
          tag: _tag
      _vm = new Vue vue_obj

      localStorage.setItem 'tagname', app.tagname
      app.se.play 'ok'
      app.screen.transition 'ApplyTag'
      app.key.load obj =
        keys:
          l: go_back
      null

    apply = () ->
      _tag.from = app.tagname
      _tag.to = _tag.name
      vue_obj =
        el: '#chose-tag-saving'
        data:
          tag: _tag
      _vm = new Vue vue_obj

      app.se.play 'click'
      app.screen.transition 'ChoseTagSaving'
      strage = new Strage

      if app.cards isnt 'localStrage' and app.cards isnt 'not found'
        cards = app.cards.getAll()
        strage.save cards, (error) ->
          if error?
            app.screen.transition 'Error'
            vue_obj =
              el: '#error'
              data:
                message: res
            _vm = new Vue vue_obj
            return null

      app.tagname = _tag.name

      if app.cards isnt 'localStrage' and app.cards isnt 'not found'
        strage.load (cards_array) ->
          cards = new Cards
          if cards_array.length > 0
            cards.create cards_array
            app.cards = cards
          else
            app.cards = 'not found'
          done()
      else
        done()
      null

    go_back = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home
      null

    ready = () ->
      app.status.message = 'タグを変更'
      _tag.name = app.tagname
      setTimeout () ->
        if window.ontouchstart isnt null
          $ '#chose-tag-input'
            .focus()
      , null
      null

    if !_vm?
      vue_obj =
        el: '#chose-tag'
        data:
          tag: _tag
      _vm = new Vue vue_obj

    app.key.load obj =
      keys:
        h: go_back
        l: apply
      input:
        ['#chose-tag-input']

    ready()

class Home
  _vm = null
  _summary =
    period:  0
    cards:   0
    learned: 0
    strage: ''

  constructor: () ->
    localStorage.setItem 'strage', app.strage
    period_stringify = (period) ->
      d = period / 1000
      sec = Math.round(d % 60)
      min = Math.floor((d / 60) % 60)
      hour = Math.floor((d/ 3600) % 60)
      res = ""
      if hour > 0
        res += "#{hour}時間"
      if min > 0
        res += "#{min}分"
      res += "#{sec}秒"

    get_period = (score) ->
      ce = 1000
      step = ['0', '1d', '1w', '4w', '999w']

      if score < 0
        score = 0
      if score > step.length - 1
        score = step.length - 1
      if step[score].match /m|h|d|w/g
        ce *= 60
      if step[score].match /h|d|w/g
        ce *= 60
      if step[score].match /d|w/g
        ce *= 24
      if step[score].match /w/g
        ce *= 7
      sec = parseInt(step[score].replace /[^\d]/g, '')
      sec * ce

    get_card = (o, fn) ->
      p   = null
      len = 0
      matched = []
      for prop of o
        len += 1
        if prop isnt 'cards'
          p = prop

      if o.cards is undefined
        return null
      for c, i in o.cards
        if len is 2 and c[p] is o[p]
          return i
        if fn?
          filtered = fn c
          if filtered isnt null
            matched.push filtered
          else
            matched.push null
      if matched.length is 0
        return null
      else
        return matched

    test = () ->
      app.se.play 'click'
      new TestCards
      null

    edit = () ->
      app.se.play 'click'
      app.screen.transition 'edit'
      new ChoseEditType
      null

    find = () ->
      compare = (card) ->
        score = card.score
        date  = card.date
        period = get_period score
        if (+new Date() - date) > period
          card
        else
          null

      if app.cards is 'not found'
        app.screen.transition 'TestNotfound'
        app.key.load obj =
          keys:
            h: go_back
        return null
      else
        app.cards.first()

      period = 0
      array = app.cards.getAll()
      for card in array
        period += card.period

      array = get_card cards: array, compare
      learning = 0
      for card in array
        if card?
          learning += 1

      res =
        learned: array.length - learning
        period: period_stringify period
      res

    chose_tag = () ->
      app.se.play 'click'
      app.screen.transition 'ChoseTag'
      new ChoseTag
      null

    ready = () ->
      app.period = 0
      if app.cards is 'not found'
        num = 0
        learned = 0
        period = 0
      else
        o = find()
        num = app.cards.getLen()
        learned = o.learned
        period = o.period

      _summary.strage = app.strage
      _summary.tagname = app.tagname
      _summary.cards = num
      _summary.learned = learned
      _summary.period = period

      if !_vm?
        vue_obj =
          el: '#home'
          data:
            summary: _summary
        _vm = new Vue vue_obj
      app.status.message = 'ようこそ'

    ready()
    app.key.load obj =
      keys:
        h: edit
        j: chose_tag
        k: chose_tag
        l: test
    null

class ChoseEditType
  _cursor = 1

  constructor: () ->
    up = () ->
      app.se.play 'blow'
      $ "#chose-edit-type-c#{_cursor}"
        .hide()
      _cursor -= 1
      if _cursor < 1
        _cursor = 4
      $ "#chose-edit-type-c#{_cursor}"
        .show()

    down = () ->
      app.se.play 'blow'
      $ "#chose-edit-type-c#{_cursor}"
        .hide()
      _cursor += 1
      if _cursor > 4
        _cursor = 1
      $ "#chose-edit-type-c#{_cursor}"
        .show()
      null

    prev = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home
      null

    bind_btn = () ->
      if window.ontouchstart is null
        $ '#btn-import'
          .off 'touchstart'
          .on 'touchstart', () ->
            app.se.play 'click'
            new ImportCards
            app.screen.transition 'ImportCards'

        $ '#btn-export'
          .off 'touchstart'
          .on 'touchstart', () ->
            app.se.play 'click'
            app.screen.transition 'ExportCards'
            new ExportCards

        $ '#btn-bywords'
          .off 'touchstart'
          .on 'touchstart', () ->
            app.se.play 'click'
            app.screen.transition 'RegisterCardsByWords'
            new RegisterCardsByWords

        $ '#btn-byhand'
          .off 'touchstart'
          .on 'touchstart', () ->
            app.se.play 'click'
            app.screen.transition 'RegisterCardsByHand'
            new RegisterCardsByHand
      else
        $ '#btn-import'
          .off 'mousedown'
          .on 'mousedown', () ->
            app.se.play 'click'
            app.screen.transition 'ImportCards'
            new ImportCards

        $ '#btn-export'
          .off 'mousedown'
          .on 'mousedown', () ->
            app.se.play 'click'
            app.screen.transition 'ExportCards'
            new ExportCards

        $ '#btn-bywords'
          .off 'mousedown'
          .on 'mousedown', () ->
            app.se.play 'click'
            app.screen.transition 'RegisterCardsByWords'
            new RegisterCardsByWords

        $ '#btn-byhand'
          .off 'mousedown'
          .on 'mousedown', () ->
            app.se.play 'click'
            app.screen.transition 'RegisterCardsByHand'
            new RegisterCardsByHand
      null

    next = () ->
      app.se.play 'click'
      $ "#chose-edit-type-c#{_cursor}"
        .hide()

      switch _cursor
        when 1
          app.screen.transition 'RegisterCardsByHand'
          new RegisterCardsByHand
        when 2
          app.screen.transition 'RegisterCardsByWords'
          new RegisterCardsByWords
        when 3
          app.screen.transition 'ExportCards'
          new ExportCards
        when 4
          app.screen.transition 'ImportCards'
          new ImportCards
      null

    app.status.message = 'メニューを選択'
    app.key.load obj =
      keys:
        h: prev
        j: down
        k: up
        l: next

    bind_btn()
    $ "#chose-edit-type-c#{_cursor}"
      .show()

#########################################################

class RegisterCardsByWords
  _cards = null
  _vm = null
  _card = null
  _status = null
  _timer = null
  _dic = null
  _dd = null

  constructor: () ->
    auto_save = () ->
      app.se.play 'ok'
      cards_array = _cards.getAll().slice 0
      n = _cards.getLen() - _cards.getNum() - 1
      loop
        if n is 0
          break
        cards_array.pop()
        n -= 1
      tmp_array = []
      Array.prototype.push.apply tmp_array, cards_array
      Array.prototype.push.apply tmp_array, app.cards.getAll()
      strage = new Strage
      strage.save tmp_array, (error) ->
        if error?
          app.screen.transition 'Error'
        $ '#notification'
          .fadeIn()
          .delay 3000
          .fadeOut()

    filter = (words_array) ->
      _dic = (JSON.parse localStorage.getItem 'dic') || []
      has_cache = (word) ->
        for local_word in _dic
          if word is local_word
            return true
        null

      new_words = []
      if app.cards is 'not found'
        app.cards = new Cards
      cards_array = app.cards.getAll()
      for word in words_array
        found = null
        for card in cards_array
          if word is card.front or has_cache(word)?
            found = true
            break
        if found is null
          new_words.push word
      new_words

    sort = (res) ->
      a = res.counts
      for v, i in a
        for j in [i .. a.length - 1]
          if a[i] < a[j]
            tmpw = res.words[i]
            tmpr = res.counts[i]
            res.words[i] = res.words[j]
            res.counts[i] = res.counts[j]
            res.words[j] = tmpw
            res.counts[j] = tmpr
      res.words

    extract = () ->
      w = []
      c = []
      res    = []
      obj = {}

      parse = (word) ->
        if word[0] is '-' or word[0] is '\''
          word = word.slice 1, (word.length)
        if word[word.length - 1] is '-' or word[word.length - 1] is '\''
          word = word.slice 0, (word.length - 1)
        word

      $ '#register-cards-by-words-input'
        .val()
        .replace '’', '\''
        .replace '.', ''
        .split /[^a-zA-Z'-]/
        .forEach (word) ->
          word = parse word.toLowerCase()
          if word isnt ''
            res[word] = if res[word]? then res[word] + 1 else 1
          null

      for key of res
        w.push key
        c.push res[key]

      obj.words = w
      obj.counts = c
      words_array = filter sort obj
      words_array

    getStatus = () ->
      status =
        num: _cards.getNum() + 1
        len: _cards.getLen()
      status

    display = () ->
      app.status.message = '札を作成中'
      setTimeout () ->
        if window.ontouchstart isnt null
          $ '#register-cards-by-words-back'
            .focus()
      , 0
      _vm.status = getStatus()
      _card = _cards.getCurrent()
      _card.link = "#{app.settings.link}#{_card.front}"
      _vm.card = _card
      new Speech _card.front
      null

    prevCard = () ->
      app.se.play 'click'
      _cards.prev()
      display()

    nextCard = () ->
      if _cards.getNext() is undefined
        save()
        return null
      app.se.play 'click'
      _cards.next()
      display()

    deleteCard = () ->
      app.se.play 'blow'
      _dic.push _card.front
      _cards.delete()
      if _cards.getLen() is 0
        app.se.play 'click'
        app.screen.transition 'home'
        localStorage.setItem 'dic', JSON.stringify _dic
        new Home
        return null
      display()
      null

    save = () ->
      app.status.message = '保存しています'
      app.se.play 'click'
      app.screen.transition 'Saving'
      localStorage.setItem 'dic', JSON.stringify _dic
      clearInterval _timer
      cards_array = _cards.getAll().slice 0
      n = _cards.getLen() - _cards.getNum() - 1
      loop
        if n is 0
          break
        cards_array.pop()
        n -= 1
      app.cards.add cards_array
      new Saving
      null

    prepare = () ->
      app.se.play 'click'
      app.screen.transition 'Regi'
      words = extract()

      if words.length is 0
        app.screen.transition 'RegisterCardsByWordsNotfound'
        app.key.load obj =
          keys:
            h: go_back
        return null

      _cards = new Cards
      _cards.create()
      for word in words
        card =
          front: word
        _cards.setCurrent card
        if words.length - 1 > _cards.getNum()
          _cards.create()
          _cards.next()
      _cards.first()

      d_d = () ->
        deleteCard() if _dd?
        if _dd?
          _dd = null
        else
          _dd = true
        null

      app.key.load obj =
        keys:
          h:  prevCard
          l:  nextCard
          w:  save
          d: d_d
        input: [
          '#register-cards-by-words-back'
        ]

      display()
      _timer = setInterval () ->
        auto_save()
      , app.settings.interval
      app.screen.transition 'RegisterCardsByWordsInput'
      null

    go_back = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home
      null

    ready = () ->
      app.status.message = '文章がら札を作成'
      setTimeout () ->
        if window.ontouchstart isnt null
          $ '#register-cards-by-words-input'
            .focus()
      , 0
      null

      if !_vm?
        vue_obj =
          el: '#register-cards-by-words-create'
          data:
            card: _card
            status: _status
        _vm = new Vue vue_obj

    app.status.message = '札を作成中'
    app.key.load obj =
      keys:
        h: go_back
        l: prepare
      input: ['#register-cards-by-words-input']

    el_input = $ '#register-cards-by-words-input'
    el_input.val ''
    ready()

#########################################################

class RegisterCardsByHand
  _strage = null
  _vm = null
  _timer = null
  _dd = null

  constructor: () ->
    getStatus = () ->
      status =
        num: app.cards.getNum() + 1
        len: app.cards.getLen()
      status

    display = () ->
      setTimeout () ->
        if window.ontouchstart isnt null
          $ '#add-cards-manually-front'
            .focus()
      , 0
      _vm.status = getStatus()
      _vm.card   = app.cards.getCurrent()
      null

    prevCard = () ->
      app.se.play 'click'
      app.cards.prev()
      display()

    nextCard = () ->
      app.se.play 'click'
      if app.cards.getNext() is undefined
        app.cards.create()
      app.cards.next()
      display()

    deleteCard = () ->
      app.se.play 'blow'
      app.cards.delete()
      if app.cards.getLen() is 0
        app.cards.create()
      display()
      null

    storeCard = () ->
      clearInterval _timer
      app.se.play 'click'
      app.screen.transition 'Saving'
      app.cards = app.cards
      cards = app.cards.getAll()
      strage = new Strage
      strage.save cards, (error) ->
        if error?
          app.screen.transition 'Error'
          vue_obj =
            el: '#error'
            data:
              message: res
          _vm = new Vue vue_obj
          return null

        app.se.play 'ok'
        app.screen.transition 'Done'
        num = app.cards.getLen()
        new Done num
        null
      null

    auto_save = () ->
      cards = app.cards.getAll()
      strage = new Strage
      strage.save cards, (error) ->
        if error?
          app.screen.transition 'Error'
        $ '#notification'
          .fadeIn()
          .delay 3000
          .fadeOut()

    ready = () ->
      _timer = setInterval () ->
        app.se.play 'ok'
        auto_save()
      , app.settings.interval
      if app.cards is 'not found'
        app.cards = new Cards
        app.cards.create()
      else
        app.cards.last()

      vue_obj =
        el: '#RegisterCardsByHand'
        data:
          card:
            front: ''
            back: ''
          status:
            len: 0
            num: 0

      if !_vm?
        _vm = new Vue vue_obj

      d_d = () ->
        deleteCard() if _dd?
        if _dd?
          _dd = null
        else
          _dd = true
        null

      app.key.load obj =
        keys:
          h:  prevCard
          l:  nextCard
          w:  storeCard
          d: d_d
        input: [
          '#add-cards-manually-front'
          '#add-cards-manually-back'
        ]
      null

    app.status.message = '編集中'
    ready()
    display()

#########################################################################

class ImportCards
  _vm = null
  _cards = {}
  _change = null

  constructor: () ->
    ready_to_load = () ->
      dropped = (file) ->
        if file.name.match /\.huda$/
          reader = new FileReader()
          reader.readAsText file
          reader.onload = (e) ->
            try
              cards_array = JSON.parse reader.result
              if app.cards is 'not found'
                app.cards = new Cards
              app.cards.create cards_array
              app.screen.transition 'ImportFinished'
              app.se.play 'right'
              app.status.message = 'インポート完了'
              app.key.load obj =
                keys:
                  l: go_back
            catch e
              app.status.message = 'エラー'
              app.se.play 'wrong'
              app.screen.transition 'ImportError'
              _cards.message = '札ファイルが破損しています。'
        else
          app.status.message = 'エラー'
          app.se.play 'wrong'
          app.screen.transition 'ImportError'
          _cards.message = '札ファイルを選択してください。'
        null

      change_handler = (e) ->
        dropped e.target.files[0]
        null

      open_file = () ->
        app.se.play 'click'
        e = document.querySelector '#cards-import-upload'
        e.value = ''
        if _change is null
          e.addEventListener 'change', change_handler, true
          _change = true
        e.click()
        e.removeEventListener 'click', this
        null

      $ '#cards-import-drop'
        .off 'dragover'
        .on 'dragover', (e) ->
          e.preventDefault()
          null
        .off 'drop'
        .on 'drop', (e) ->
          e.preventDefault()
          dropped e.originalEvent.dataTransfer.files[0]
          null
        .off 'touchstart'
        .on 'touchstart', () ->
          open_file()
          null
        .off 'mousedown'
        .on 'mousedown', () ->
          if window.ontouchstart isnt null
            open_file()
          null
      null

    go_back = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home
      null

    if !_vm?
      vue_obj =
        el: '#cards-import-error'
        data:
          cards: _cards
      new Vue vue_obj

    app.status.message = 'インポート'
    ready_to_load()
    app.key.load obj =
      keys:
        h: go_back
    null

#####################################################################

class ExportCards
  _vm = null
  _cards = {}

  constructor: () ->
    create_file = () ->
      if app.cards isnt 'not found'
        array = JSON.stringify app.cards.getAll()
        blob = new Blob [array], type: 'application/x-huda'
        window.URL = window.URL || window.webkitURL
        file_uri = window.URL.createObjectURL blob

        _cards.filename = "#{app.tagname}.huda"
        _cards.href = file_uri
        _cards.download = "#{app.tagname}.huda"
        setTimeout () ->
          e = document.querySelector '#cards-backup-export-link'
          e.click()
        , 100
        null

    go_back = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home
      null

    if !_vm?
      vue_obj =
        el: '#cards-export'
        data:
          cards: _cards

      new Vue vue_obj

    create_file()
    app.status.message = 'エクスポート'
    app.key.load obj =
      keys:
        h: go_back
    null

#####################################################################

class Saving
  constructor: () ->
    app.key.reset()
    strage = new Strage
    strage.save app.cards.getAll(), (error) ->
      if error?
        app.se.play 'wrong'
        return null
      setTimeout () ->
        app.se.play 'ok'
        app.screen.transition 'Done'
      , 500
      new Done

################################################################

class Done
  constructor: (num) ->
    next = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home

    cards =
      num: app.cards.getLen()
      strage: app.strage

    vue_obj =
      el: '#done'
      data:
        cards: cards

    new Vue vue_obj
    app.key.load obj =
      keys:
        l: next

    app.status.message = '保存しました'
    null

class TestCards
  constructor: () ->
    app.q_limit = 10
    app.q_num = 0
    get_step = () ->
      ['0', '1d', '1w', '4w', '999w']

    get_period = (score) ->
      ce = 1000
      step = get_step()
      if score < 0
        score = 0
      if score > step.length - 1
        score = step.length - 1
      if step[score].match /m|h|d|w/g
        ce *= 60
      if step[score].match /h|d|w/g
        ce *= 60
      if step[score].match /d|w/g
        ce *= 24
      if step[score].match /w/g
        ce *= 7
      sec = parseInt(step[score].replace /[^\d]/g, '')
      sec * ce

    get_card = (o, fn) ->
      p   = null
      len = 0
      matched = []
      for prop of o
        len += 1
        if prop isnt 'cards'
          p = prop

      if o.cards is undefined
        return null
      for c, i in o.cards
        if len is 2 and c[p] is o[p]
          return i
        if fn?
          filtered = fn c
          if filtered isnt null
            matched.push filtered
          else
            matched.push null
      if matched.length is 0
        return null
      else
        return matched

    go_back = () ->
      app.se.play 'click'
      app.screen.transition 'home'
      new Home
      null

    find = () ->
      compare = (card) ->
        score = card.score
        date  = card.date
        period = get_period score
        if (+new Date() - date) > period
          card
        else
          null

      if app.cards is 'not found'
        app.screen.transition 'TestNotfound'
        app.key.load obj =
          keys:
            h: go_back
        return null

      app.mirror_cards = new Cards
      mirror_cards_array = get_card cards: app.cards.getAll(), compare
      app.mirror_cards.create mirror_cards_array

      loop
        if app.mirror_cards.getCurrent()?
          app.screen.transition 'TestQuestion'
          new TestQuestion
          return null

        if app.mirror_cards.getNext() is undefined
          app.screen.transition 'TestLearned'
          app.key.load obj =
            keys:
              h: go_back
          return null

        app.cards.next()
        app.mirror_cards.next()
      null

    find()
    app.right = 0
    app.wrong = 0
    app.forgot = 0
    null

#########################################################

class TestQuestion
  _vm = null
  _card = null

  constructor: () ->
    app.status.message = 'オモテ'
    app.date = +new Date()
    app.q_num += 1

    next = () ->
      app.se.play 'click'
      app.screen.transition 'TestAnswer'
      new TestAnswer
      null

    forgot = () ->
      app.se.play 'blow'
      app.forgot += 1
      card = app.mirror_cards.getCurrent()
      period = +new Date() - app.date

      card.period = period
      app.cards.setCurrent card
      app.period += period
      loop
        if app.mirror_cards.getNext() is undefined or app.q_num is app.q_limit
          app.screen.transition 'TestResult'
          new TestResult
          break
        app.cards.next()
        app.mirror_cards.next()
        if app.mirror_cards.getCurrent()?
          new TestQuestion
          break
      null

    card = app.cards.getCurrent()
    card.front_chars = card.front.split('').toString().replace /,/g, ', ... '
    new Speech card.front
    if _vm?
      _vm.card = card
    else
      vue_obj =
        el: '#test-question'
        data:
          card: card
      _vm = new Vue vue_obj

    app.key.load obj =
      keys:
        h: forgot
        l: next
    null

################################################################

class TestAnswer
  _vm = null
  _ab = null
  _cardA = null
  _cardB = null
  _message = null
  _next = null

  constructor: () ->
    _score = 0
    get_ab = () ->
      array = []
      if Math.floor(Math.random() * 2) is 0
        array.push 'A'
      else
        array.push 'B'
      if array[0] is 'A'
        array.push 'B'
      else
        array.push 'A'
      array

    get_wrong = () ->
      len = app.cards.getLen()
      random = () -> Math.floor(Math.random() * len)
      if app.cards.getLen() is 1
        return 'ウラがありません'
      n = random()
      while n is app.cards.getNum()
        n = random()
      wrong_card = app.cards.getCard n
      wrong_card.back

    next = () ->
      app.se.play 'click'
      app.screen.transition 'TestQuestion'

      $ '#test-answer-ab'
        .fadeIn()
      $ '#test-answer-next'
        .hide()

      card = app.cards.getCurrent()
      period = +new Date() - app.date
      card.period += period
      app.period += period
      card.date = +new Date()
      card.score += _score
      if card.score < 0
        card.score = 0
      app.cards.setCurrent card

      $ "#test-answer-back-A-good"
        .hide()
      $ "#test-answer-back-B-good"
        .hide()

      loop
        if app.mirror_cards.getNext() is undefined or app.q_num is app.q_limit
          app.screen.transition 'TestResult'
          new TestResult
          break
        app.cards.next()
        app.mirror_cards.next()
        if app.mirror_cards.getCurrent()?
          new TestQuestion
          break
      null

    show_message = (flag) ->
      if flag is 'right'
        app.status.message = '正解'
      if flag is 'wrong'
        app.status.message = '残念'

    chose_a = () ->
      chose 'A'
      null

    chose_b = () ->
      chose 'B'
      null

    chose = (A_or_B) ->
      $ '#test-answer-ab'
        .hide()
      $ '#test-answer-next'
        .fadeIn()

      if _ab[0] is A_or_B
        if _ab[0] is 'A'
          _cardA.style = 'background-color: #4A1; color: #FFF;'
        else
          _cardB.style = 'background-color: #4A1; color: #FFF;'

        app.se.play 'right'
        app.right += 1
        show_message 'right'
        _score = 1
      else
        if _ab[0] is 'A'
          _cardB.style = 'background-color: #E66; color: #FFF'
        else
          _cardA.style = 'background-color: #E66; color: #FFF'
        app.se.play 'wrong'
        show_message 'wrong'
        app.wrong += 1
        _score = 0
      $ "#test-answer-back-#{_ab[0]}-good"
        .show()

      app.key.load obj =
        keys:
          l: next
      null

    _ab  = get_ab()
    wrong = get_wrong()
    right = app.cards.getCurrent().back
    if _ab[0] is 'A'
      _cardA =
       back: right
      _cardB =
       back: wrong
    else
      _cardA =
       back: wrong
      _cardB =
       back: right

    if _vm?
      show_message()
      _vm.cardA = _cardA
      _vm.cardB = _cardB
    else
      $ '#test-answer-ab'
        .fadeIn()
      $ '#test-answer-next'
        .hide()

      message =
        text: 'ウラを選択して下さい'
      vue_obj =
        el: '#test-answer'
        data:
          cardA: _cardA
          cardB: _cardB
          message: message
          ab: _ab
          next: _next
      _vm = new Vue vue_obj

    app.key.load obj =
      keys:
        j: chose_b
        k: chose_a

    app.status.message = 'ウラを選択してください'
    null

#################################################################

class TestResult
  _vm = null

  constructor: () ->
    next = () ->
      app.se.play 'click'
      app.screen.transition 'Saving'
      new Saving

    get_period = (period) ->
      d = period / 1000
      sec = Math.round(d % 60)
      min = Math.floor((d / 60) % 60)
      hour = Math.floor((d/ 3600) % 60)
      res = ""
      if hour > 0
        res += "#{hour}時間"
      if min > 0
        res += "#{min}分"
      res += "#{sec}秒"

    period = get_period app.period

    result =
      period: period
      right: app.right
      wrong: app.wrong
      forgot: app.forgot

    if _vm?
      _vm.result = result
    else
      vue_obj =
        el: '#test-result'
        data:
          result: result
      _vm = new Vue vue_obj

    app.status.message = 'テスト終了'
    app.key.load obj =
      keys:
        l: next

