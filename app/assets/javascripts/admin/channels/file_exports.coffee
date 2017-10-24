App.Admin ||= {}

class App.Admin.FileExportsSubscription
  constructor: (user_id) ->
    App.Admin.exports = App.cable.subscriptions.create {channel: "FileExportsChannel", user_id: user_id},

      connected: ->
        console.log 'Connected'
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        console.log data
        $('#js-waiting').hide()
        window.location = data.url
