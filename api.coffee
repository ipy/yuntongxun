js2xmlparser = require 'js2xmlparser'
request = require 'request'
{getTimestamp, getAuthorization, getSig, merge} = require './util'

create = (config) ->
  accountSid = config.accountSid
  authToken = config.authToken
  appId = config.appId
  baseUrl = config.baseUrl
  softVersion = config.softVersion
  if config.log then log = config.log
  else
    log = (e, r, b, action) ->
      if e then console.log '\n' + e
      else
        if action then console.log '\nResult of ' + action + ':'
        console.log '\n'
        console.dir b

  callApi = (args) ->
    unless args.format
      if (/\/ivr\//i).test args.api
        args.format = 'XML'
      else
        args.format = 'JSON'
    else
      args.format = args.format.toUpperCase()
    unless args.method
      args.method = 'POST'
    else
      args.method = args.method.toUpperCase()
    if (/{accountSid}/i).test args.api
      sid = accountSid
      token = authToken
    else if (/{subAccountSid}/i).test args.api
      sid = args.sid
      token = args.token
      if not sid or not token
        throw new Error 'subaccount sid and token are required.'
    uri = baseUrl + 
      args.api.replace(/{SoftVersion}/i, softVersion)
      .replace(/{(sub)?accountSid}/i, sid)
    timestamp = getTimestamp()
    headers =
      'Authorization': getAuthorization(sid, timestamp)
      'Accept': 'application/json'
    if args.format is 'JSON'
      headers['Content-Type'] ='application/json;charset=utf-8;'
    else if args.format is 'XML'
      headers['Content-Type'] ='application/xml;charset=utf-8;'
    options =
      method: args.method
      uri: uri
      followAllRedirects: true
      rejectUnauthorized: false
      timeout: 5000
      headers: headers
    unless args.params then args.params = {}
    if args.method is 'GET'
      args.params.appId = appId
      options.qs = args.params
    else
      if args.format is 'JSON'
        args.params.appId = appId
        options.json = args.params
      else if args.format is 'XML'
        unless args.params.data then pargs.arams.data = {}
        args.params.data['Appid'] = appId
        options.body = js2xmlparser args.params.root or 'Request', args.params.data
    unless options.qs then options.qs = {}
    options.qs.sig = getSig(sid, token, timestamp)
    request options, (e, r, b) ->
      if typeof b is 'string'
        try
          b = JSON.parse b
        catch e
          return callback? new Error 'Parse response error: ' + b
      args.callback? e, r, b

  apiFactory = (name, api, method) ->
    (args, callback) ->
      if typeof args is 'function'
        callback = args
        args = {}
      callApi
        method: method or 'POST'
        api: api
        params: args
        callback: (e, r, b) ->
          log e, r, b, name
          callback? e, r, b
  confApiFactory = (action) ->
    params = {}
    if action.toLowerCase() is 'createconf'
      api = '/{SoftVersion}/Accounts/{accountSid}/ivr/createconf'
    else
      api = '/{SoftVersion}/Accounts/{accountSid}/ivr/conf?confid={id}'
    (args, callback) ->
      if typeof args is 'function'
        callback = args
        args = {}
      params.root = 'Request'
      params.data = {}
      params.data[action] = {}
      params.data[action]['@'] = args
      callApi
        api: api.replace '{id}', args.confid
        params: params
        callback: (e, r, b) ->
          log e, r, b, action
          callback? e, r, b

  # Account
  accountInfo: apiFactory 'AccountInfo', '/{SoftVersion}/Accounts/{accountSid}/AccountInfo', 'get'
  createSubAccount: apiFactory 'CreateSubAccount', '/{SoftVersion}/Accounts/{accountSid}/SubAccounts'
  getSubAccounts: apiFactory 'GetSubAccounts', '/{SoftVersion}/Accounts/{accountSid}/GetSubAccounts'
  querySubAccountByName: apiFactory 'QuerySubAccountByName', '/{SoftVersion}/Accounts/{accountSid}/QuerySubAccountByName'
  closeSubAccount: apiFactory 'CloseSubAccount', '/{SoftVersion}/Accounts/{accountSid}/CloseSubAccount'
  # Bill
  billRecords: apiFactory 'BillRecords', '/{SoftVersion}/Accounts/{accountSid}/BillRecords'
  # SMS
  message: apiFactory 'Message', '/{SoftVersion}/Accounts/{accountSid}/SMS/Messages'
  templateSMS: apiFactory 'TemplateSMS', '/{SoftVersion}/Accounts/{accountSid}/SMS/TemplateSMS'
  # Call
  callback: apiFactory 'Callback', '/{SoftVersion}/SubAccounts/{subAccountSid}/Calls/Callback'
  landingCalls: apiFactory 'LandingCalls', '/{SoftVersion}/Accounts/{accountSid}/Calls/LandingCalls'
  voiceVerify: apiFactory 'VoiceVerify', '/{SoftVersion}/Accounts/{accountSid}/Calls/VoiceVerify'
  # IVR Conf
  createConf: confApiFactory 'CreateConf'
  dismissConf: confApiFactory 'DismissConf'
  joinConf: confApiFactory 'JoinConf'
  inviteJoinConf: confApiFactory 'InviteJoinConf'
  quitConf: confApiFactory 'QuitConf'
  confMute: confApiFactory 'ConfMute'
  confUnMute: confApiFactory 'ConfUnMute'
  confPlay: confApiFactory 'ConfPlay'
  confStopPlay: confApiFactory 'ConfStopPlay'
  confRecord: confApiFactory 'ConfRecord'
  confStopRecord: confApiFactory 'ConfStopRecord'
  confVolumeAdjust: confApiFactory 'ConfVolumeAdjust'
  confMemberPause: confApiFactory 'ConfMemberPause'
  confMemberResume: confApiFactory 'ConfMemberResume'
  confAlarmClock: confApiFactory 'ConfAlarmClock'
  queryConfState: confApiFactory 'QueryConfState'

exports.create = create