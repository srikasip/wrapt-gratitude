#= require jquery.pjax

#############
# Ajax modals
#############

class window.PjaxModalBase
  constructor: (modalSelector, linkTriggerSelector, formTriggerSelector) ->
    @modal = $(modalSelector)
    @container = @modal.find("[data-pjax-modal-container]")
    @title = @modal.find("[data-pjax-modal-title]")
    @body = @modal.find("[data-pjax-modal-body]")
    @footer = @modal.find("[data-pjax-modal-footer]")
    @linkTriggers = $(linkTriggerSelector)
    @formTriggers = $(formTriggerSelector)
    @loading = @modal.find("[data-pjax-modal-loading]")

  listen: ->
    @_registerLoadingIndicator()
    @_registerLinks()
    @_registerForms()
    @_registerClose()

  _registerLoadingIndicator: ->
    $('body').on 'pjax:send', =>
      @loading.show()
    $('body').on 'pjax:complete', =>
      @loading.hide()

  _registerLinks: ->
    $('body').pjax @linkTriggers.selector, @container.selector, timeout: false, push: false
    $('body').on 'click', @linkTriggers.selector, (e) =>
      @body.hide()
      @footer.hide()
      @open()

  _registerForms: ->
    $('body').on 'submit', @formTriggers.selector, (evt) =>
      @open()
      $.pjax.submit evt, @container.selector, timeout: false, push: false

  _registerClose: ->
    $('body').on 'click', '[pjax-modal-close]', (e) =>
      @closeModal()

  closeModal: ->
    $('.js-ios-hack').show()
    $('body').css(position: 'static')
    @modal.modal('hide')
    @reset()

  open: ->
    @modal.modal('show')

    # iOS 11 devices like iPhone 8 can display the cursor in the wrong
    # place on the screen when the keyboard shows up. Hiding everything
    # besides the modal seems to fix it.
    # https://hackernoon.com/how-to-fix-the-ios-11-input-element-in-fixed-modals-bug-aaf66c7ba3f8
    if navigator.userAgent.match(/iPhone/)
      $('.js-ios-hack').hide()
      $('body').css(position: 'fixed')

  reset: ->
    @title.html("")
    @body.html("")
    @footer.html("")
    @loading.show()

class window.PjaxModal extends window.PjaxModalBase
  constructor: ->
    super(".modal[data-pjax-modal]", '[data-loads-in-pjax-modal]', '[data-submits-to-pjax-modal]')

class window.PjaxModalTwo extends window.PjaxModalBase
  constructor: ->
    super(".modal[data-pjax-modal-two]", '[data-loads-in-pjax-modal-two]', '[data-submits-to-pjax-modal-two]')

  reset: ->
    super()
    @formTriggers.find('input[type="submit"]').removeAttr('disabled')


