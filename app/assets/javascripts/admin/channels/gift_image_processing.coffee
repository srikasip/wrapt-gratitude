App.Admin ||= {}

class App.Admin.GiftImageProcessingSubscription
  constructor: (gift_id) ->
    App.Admin.gift_image_processing = App.cable.subscriptions.create {channel: "GiftImageProcessingChannel", gift_id: gift_id},
      connected: ->
        console.log 'Connected'
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        console.log data
        gift_image_id = data.image_record_id
        $("[data-gift-image-id=#{gift_image_id}]").html data.html