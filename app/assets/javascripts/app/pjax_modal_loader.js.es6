// used to load a modal on page load without the user
// having to click anything
App.PjaxModalLoader = class PjaxModalLoader {
  constructor(url) {
    $.pjax({
      url: url,
      container: "[data-pjax-modal-container]"
    })
    $(".modal[data-pjax-modal]").modal('show')

  }

}

