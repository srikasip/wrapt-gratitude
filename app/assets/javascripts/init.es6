window.App || (window.App = {})

App.init = function(){
  $('[data-provide="slider"]').slider()
}

$(document).on( "turbolinks:load", ( () => App.init()) )