crypto = require 'crypto'

padZero = (str, len) ->
  unless len then len = 2
  if typeof str isnt 'string'
    str = str.toString()
  while str.length < len
    str = '0' + str
  str
formatDate = (date) ->
  # yyyyMMddHHmmss
  unless date instanceof Date
    date = new Date Date.parse date
  '' + date.getFullYear() +
    padZero(date.getMonth() + 1) +
    padZero(date.getDate()) +
    padZero(date.getHours()) +
    padZero(date.getMinutes()) +
    padZero(date.getSeconds())
getTimestamp = () ->
  formatDate new Date()

md5 = (str, type='hex') ->
  md5sum = crypto.createHash 'md5'
  md5sum.update str
  md5sum.digest type

base64 = (str) ->
  (new Buffer(str)).toString('base64')

getAuthorization = (sid, timestamp) ->
  base64(sid + ':' + timestamp)

getSig = (sid, token, timestamp) ->
  md5(sid + token + timestamp).toUpperCase()

merge = (src, adds...) ->
  for add in adds
    for k,v of add
      src[k] = v
  src

exports.formatDate = formatDate
exports.getTimestamp = getTimestamp
exports.md5 = md5
exports.base64 = base64
exports.getAuthorization = getAuthorization
exports.getSig = getSig
exports.merge = merge