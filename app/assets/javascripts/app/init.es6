window.App || (window.App = {})

App.init = function(){
  console.log($('[data-provide="slider"]'))
  $('[data-provide="slider"]').bootstrapSlider()
}

$(document).on( "turbolinks:load", ( () => App.init()) )