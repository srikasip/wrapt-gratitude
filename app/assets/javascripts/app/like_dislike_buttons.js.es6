App.GiftLikeDislikeButtons = class GiftLikeDislikeButtons {
  constructor() {
    // TODO accomodate gift disklikes too
    $('[data-behavior~=gift-like-wrapper]').on('ajax:success', (event, data) => {
      $(event.currentTarget).html(data)
    })
  }
}