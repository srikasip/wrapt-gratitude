App.GiftLikeDislikeButtons = class GiftLikeDislikeButtons {
  constructor() {
    $('[data-behavior~=gift-like-wrapper]').on('ajax:success', (event, data) => {
      $(event.currentTarget).html(data)
    })

    $('[data-behavior~=gift-dislike-wrapper]').on('ajax:success', (event, data) => {
      $(event.currentTarget).html(data)
    })
  }
}