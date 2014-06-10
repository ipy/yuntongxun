fs = require 'fs'
path = require 'path'
{init} = require '../api'
uuid = require 'uuid'
should = require 'should'

config = JSON.parse fs.readFileSync path.resolve __dirname, 'test.config.json'

describe 'api', ->
  api = null
  before ->
    api = init
      accountSid: config.accountSid
      authToken: config.authToken
      appId: config.appId
      baseUrl: 'https://sandboxapp.cloopen.com:8883'
      softVersion: '2013-12-26'
      log: (e, r, b, action) ->
        if e then return console.log e
        if action
          console.log 'Result of ' + action + ':'
        console.log b
  # accountInfo
  describe 'accountInfo', ->
    it 'should return account info', (done) ->
      api.accountInfo (e, r, b) ->
        if e then return done e
        b.should.be.an.Object
        b.statusCode.should.equal '000000'
        done()
  # createSubAccount
  describe 'createSubAccount', ->
    name = uuid()
    it 'should create a subaccount', (done) ->
      api.createSubAccount
        friendlyName: name
      , (e ,r, b) ->
        if e then return done e
        b.should.be.an.Object
        b.statusCode.should.equal '000000'
        b.SubAccount.should.be.an.Object
        b.SubAccount.should.have.keys [
          'subAccountSid', 'voipAccount', 'dateCreated',
          'voipPwd', 'subToken'
        ]
        b.SubAccount.voipAccount.should.match /^\d+$/
        done()
  # closeSubAccount
    # it 'should close a subaccount', (done) ->
    #   api.createSubAccount
    #     friendlyName: uuid()
    #   , (e, r, b) ->
    #     subAccountSid = b.SubAccount.subAccountSid
    #     api.closeSubAccount
    #       subAccountSid: subAccountSid
    #     , (e, r, b) ->
    #       if e then return done e
    #       b.should.be.an.Object
    #       b.statusCode.should.equal '000000'
    #       done()
  # getSubAccounts
  # describe 'getSubAccounts', ->
  #   it 'should return subaccounts', (done) ->
  #     api.getSubAccounts (e, r, b) ->
  #       if e then return done e
  #       b.statusCode.should.equal '000000'
  #       b.SubAccount.should.be.an.Array
  #       if b.SubAccount.length > 0
  #         b.SubAccount[0].should.have.keys [
  #           'subAccountSid', 'voipAccount', 'dateCreated',
  #           'friendlyName', 'voipPwd', 'subToken'
  #         ]
  #       done()
  # querySubAccountByName
  # billRecords


  # createConf
  # dismissConf
  # joinConf
  # inviteJoinConf
  # quitConf
  # confMute
  # confUnMute
  # confPlay
  # confStopPlay
  # confRecord
  # confStopRecord
  # confVolumeAdjust
  # confMemberPause
  # confMemberResume
  # confAlarmClock
  # queryConfState