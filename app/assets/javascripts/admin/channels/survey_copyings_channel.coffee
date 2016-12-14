App.Admin ||= {}

class App.Admin.SurveyCopyingsChannel
  constructor: () ->
    @subscription = App.cable.subscriptions.create "SurveyCopyingsChannel",
      connected: ->
        console.log 'Connected'
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        survey_id = data.survey_id
        $("[data-survey-id=#{survey_id}]").replaceWith data.html