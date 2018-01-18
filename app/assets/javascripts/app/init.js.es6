window.App || (window.App = {})

// This function runs after every turbolinks page load or
// PjaxModal modal frame load
App.init = function(){
  $('[data-provide="slider"]').bootstrapSlider();
  // TODO fix tooltips
  // $('[data-toggle="tooltip"]').tooltip()
}

$(document).on( "turbolinks:load pjax:success", ( () => App.init()) )

//can't be part of App.init because it causes double submissions
$(document).on( "turbolinks:load", () => {
  (new window.PjaxModal).listen(); 
  (new window.PjaxModalTwo).listen();
});