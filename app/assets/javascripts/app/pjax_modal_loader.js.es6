// used to load a modal on page load without the user
// having to click anything
App.PjaxModalLoader = class PjaxModalLoader {
  constructor(url, modal_options={}) {
    $.pjax({
      url: url,
      container: "[data-pjax-modal-container]",
      push: false
    })
    if(modal_options) {
      $(".modal[data-pjax-modal]").modal(modal_options)
      if (navigator.userAgent.match(/iPhone/)) {
        $('.js-ios-hack').hide()
        $('body').css({position: 'fixed'})
      }
    }
    else{
      $(".modal[data-pjax-modal]").modal('show')
      if (navigator.userAgent.match(/iPhone/)) {
        $('.js-ios-hack').hide()
        $('body').css({position: 'fixed'})
      }
    }

  }

}

