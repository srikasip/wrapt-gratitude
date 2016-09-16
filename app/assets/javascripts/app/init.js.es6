window.App || (window.App = {})

// This function runs after every turbolinks page load or
// PjaxModal modal frame load
App.init = function(){
  $('[data-provide="slider"]').bootstrapSlider();
  // TODO fix tooltips
  // $('[data-toggle="tooltip"]').tooltip()
  (new window.PjaxModal).listen()
}

$(document).on( "turbolinks:load pjax:success", ( () => App.init()) )