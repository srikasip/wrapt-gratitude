// top-level manifest for admin section
// we require all application code from the main app + special admin-only scripts

// Vendored Libraries
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require bootstrap-slider
//= require jquery-ui
//= require jquery.ui.widget
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require cable

// Application Code
//= require app/init
//= require admin/init
//= require_tree ./app
//= require_tree ./admin
