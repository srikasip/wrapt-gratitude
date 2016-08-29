window.App || (window.App = {})

App.init = function(){
  $('[data-provide="slider"]').bootstrapSlider()
}

$(document).on( "turbolinks:load", ( () => App.init()) )