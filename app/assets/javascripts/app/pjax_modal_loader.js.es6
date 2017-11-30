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
    }
    else{
      $(".modal[data-pjax-modal]").modal('show')
    }

  }

}

