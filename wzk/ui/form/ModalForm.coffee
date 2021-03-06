goog.provide 'wzk.ui.form.ModalForm'

goog.require 'wzk.ui.dialog.Dialog'
goog.require 'wzk.ui.form.AjaxForm'
goog.require 'wzk.ui.form.BackgroundForm'
goog.require 'goog.events.EventTarget'
goog.require 'goog.events.Event'

class wzk.ui.form.ModalForm extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @CLS:
    AJAX: 'ajax'

  ###*
    @enum {string}
  ###
  @EventType:
    SUCCESS_CLOSE: 'success-close'

  ###*
    @constructor
    @extends {goog.events.EventTarget}
    @param {wzk.dom.Dom} dom
    @param {wzk.resource.Client} client
    @param {string} url
    @param {string} form a snippet name
    @param {wzk.app.Register} register
  ###
  constructor: (@dom, @client, @url, @form, @register) ->
    super()
    @dialog = new wzk.ui.dialog.Dialog undefined, undefined, @dom
    @dialog.setButtonSet null
    @ajax = new wzk.ui.form.AjaxForm @client, @dom
    @ajax.listen wzk.ui.form.BackgroundForm.EventType.SAVED, @handleSave
    @ajax.listen wzk.ui.form.BackgroundForm.EventType.ERROR, @handleResponse

  ###*
    @suppress {checkTypes}
  ###
  open: ->
    @client.sniff @url, @handleResponse

  ###*
    @protected
    @param {Object} response
  ###
  handleResponse: (response) =>
    if response['snippets'][@form]
      @dialog.setContent response['snippets'][@form]
      el = @dialog.getContentElement()
      form = @dom.one('form', el)
      if goog.dom.classes.has form, wzk.ui.form.ModalForm.CLS.AJAX
        goog.dom.classes.remove form, wzk.ui.form.ModalForm.CLS.AJAX
      @ajax.decorate form
      @register.process el
      @dialog.setVisible true

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSave: (e) =>
    if e.target and e.target['snippets']
      @handleResponse e.target
    else
      @dialog.setVisible false
      @dispatchEvent new goog.events.Event(wzk.ui.form.ModalForm.EventType.SUCCESS_CLOSE, e.target)

  ###*
    @param {string} title
  ###
  setTitle: (title) ->
    @dialog.setTitle title
