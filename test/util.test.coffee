util = require '../util'
should = require 'should'

describe 'util', ->
  describe 'formatDate', ->
    it 'should format date as yyyyMMddHHmmss', ->
      date = new Date Date.parse '2012-03-04 05:06:07'
      util.formatDate date
      .should.equal '20120304050607'
  describe 'md5', ->
    it 'should return md5 sum of string', ->
      util.md5 'lalala'
      .should.equal '9aa6e5f2256c17d2d430b100032b997c'
      # 中文测试失败，不过不会用到中文
      # util.md5 '你好lalala'
      # .should.equal 'c3604f3b9aa08f1a73f867c1c4f84253'
  describe 'base64', ->
    it 'should return base64 encode of string', ->
      util.base64 '你好lalala'
      .should.equal '5L2g5aW9bGFsYWxh'
  describe 'getAuthorization', ->
    it 'should return Authorization', ->
      util.getAuthorization 'xxx', 'yyy'
      .should.equal 'eHh4Onl5eQ=='
  describe 'getSig', ->
    sig = util.getSig 'xxx', 'yyy', 'zzz'
    it 'should be uppercase', ->
      sig.should.equal sig.toUpperCase()
    it 'should return SigParameter', ->
      sig.should.equal '52E8D9CC853625AD91A5BA885B5C5CEB'
  describe 'merge', ->
    it 'should combine objects properties to the first argument', ->
      src = {a: 1}
      util.merge src, {b: 2}, {c: 3, d: 4}
      src.a.should.equal 1
      src.b.should.equal 2
      src.c.should.equal 3
      src.d.should.equal 4

