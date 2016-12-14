window.App || (window.App = {})
window.App.Admin || (window.App.Admin = {})

// This function runs after every turbolinks page load or
// PjaxModal modal frame load
App.Admin.init = function(){
}

$(document).on( "turbolinks:load pjax:success", ( () => App.Admin.init()) )