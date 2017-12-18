#= require jquery.pjax

#############
# Ajax modals
#############

class window.PjaxModal
  constructor: ->
    @modal = $(".modal[data-pjax-modal]")
    @container = @modal.find("[data-pjax-modal-container]")
    @title = @modal.find("[data-pjax-modal-title]")
    @body = @modal.find("[data-pjax-modal-body]")
    @footer = @modal.find("[data-pjax-modal-footer]")
    @linkTriggers = $('[data-loads-in-pjax-modal]')
    @formTriggers = $('[data-submits-to-pjax-modal]')
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



  reset: ->
    @title.html("")
    @body.html("")
    @footer.html("")
    @loading.show()
