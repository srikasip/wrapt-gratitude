App.Admin ||= {}

class App.Admin.ProductImageProcessingSubscription
  constructor: (product_id) ->
    App.Admin.product_image_processing = App.cable.subscriptions.create {channel: "ProductImageProcessingChannel", product_id: product_id},
      connected: ->
        console.log 'Connected'
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        console.log data
        product_image_id = data.product_image_id
        $("[data-product-image-id=#{product_image_id}]").html data.html