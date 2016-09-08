window.App || (window.App = {})

App.init = function(){
  $('[data-provide="slider"]').bootstrapSlider();
  (new window.PjaxModal).listen()
}

$(document).on( "turbolinks:load", ( () => App.init()) )