$().ready () ->
  check = () ->
    s = location.href
    arr = s.split '='
    token = arr[arr.length - 1]
    if token.match 'http'
      return null
    token

  post = (code) ->
    folder_id = 0
    alert 'push'

    $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%20%3D%20'https%3A%2F%2Fwww.box.net%2Fapi%2F1.0%2Frest%3Faction%3Dget_account_tree%26auth_token%3D#{window.auth_token}%26api_key%3D#{window.api_key}%26folder_id%3D#{folder_id}%26params[]%3Donelevel%26params[]%3Dnozip'&amp;format=json&amp;diagnostics=true", (res) ->
      alert 'done'
      console.log res

  # $.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%20%3D%20'https%3A%2F%2Fwww.box.net%2Fapi%2F1.0%2Frest%3Faction%3Dget_account_tree%26auth_token%3D" + window.auth_token + "%26api_key%3D" + window.api_key + "%26folder_id%3D" + folder_id + "%26params[]%3Donelevel%26params[]%3Dnozip'&amp;format=json&amp;diagnostics=true", function(response) {});


    #csec = 'sqDs3i8xAaZzJXSqNgYqWgEgYBrtMfe6'
    #cid  = 'z37e0bip3oq4wc719pd2xso6ghc3mwjl'
    #url  = 'https://api.box.com/oauth2/token'
    #params = "grant_type=authorization_code&code=#{code}&client_id=#{cid}&client_secret=#{csec}"
    #ajax_obj =
    #  url: url
    #  data: params
    #  contentType: 'application/x-www-form-urlencoded'
    #  type: 'POST'
    #  dataType: 'json'
    #$.ajax ajax_obj
    #  .done (data) ->
    #    console.log data

    # req = new XMLHttpRequest()
    # req.open 'POST', url, true
    # req.setRequestHeader 'Content-type', 'application/x-www-form-urlencoded'
    # req.setRequestHeader 'Content-length', params.length
    # req.setRequestHeader 'Connection', 'close'
    # req.onreadystatechange = () ->
    #   if req.readyState is 4 and req.status >= 200
    #     console.log req.responseText
    # req.send params

  _token = null

  $ '#post'
    .click () ->
      if _token?
        post _token

  $ '#push'
    .click () ->
      location.href = 'https://app.box.com/api/oauth2/authorize?response_type=code&client_id=z37e0bip3oq4wc719pd2xso6ghc3mwjl&redirect_uri=http%3a%2f%2flocalhost%3a4567%2fbox%2ehtml&state=security_token%3DKnhMJatFipTAnM0nHlZA'

  _token = check()
  window.auth_token = _token
  window.api_key = 'z37e0bip3oq4wc719pd2xso6ghc3mwjl'
  console.log _token





