goog.require 'wzk.obj'
goog.require 'goog.object'

class wzk.net.FlashMiddleware

  ###*
    @enum {string}
  ###
  @MSGS:
    'error': 'Internal error occured. Service is unavailable, sorry.'
    'loading': 'Loading...'

  ###*
    @param {wzk.ui.Flash} flash
    @param {Object.<string, string>} msgs
  ###
  constructor: (@flash, @msgs) ->
    wzk.obj.merge @msgs, wzk.net.FlashMiddleware.MSGS

  ###*
    @param {Object} res
    @param {number} status
  ###
  apply: (res, status) ->
    return if @hasDefaultMsgFor status

    if res['errors']?
      if goog.isArray(res['errors']) or goog.isString(res['errors'])
        @flash.addError res['errors']
    else if res['error']?
      @flash.addError res['error']

    msgs = res['messages'] ? res['message']
    if msgs?
      for type, msg of msgs
        @flash.addMessage msg, type

  ###*
    @protected
    @param {number} status
    @return {boolean}
  ###
  hasDefaultMsgFor: (status) ->
    goog.object.containsKey(@msgs, String(status))

  ###*
    @param {number} status
  ###
  error: (status) ->
    if @hasDefaultMsgFor status
      strStatus = String status
      @flash.addError(@msgs[strStatus]) if @msgs[strStatus]?
    else
      @flash.addError @msgs['error']

  loading: ->
    msg = new wzk.ui.FlashMessage dom: @flash.getDomHelper(), msg: @msgs['loading'], severity: 'info', fadeOut: false, closable: false
    msg.addClass 'loading'
    @flash.addChild msg
    [msg]

  clearAll: ->
    @flash.clearAll()
