App.GiftBasket = class GiftBasket {
  constructor(options = {}) {
    this.container = $('[data-behavior~=gift-basket-container]')[0];
    this.overlay = $('[data-behavior~=gift-basket-overlay]')[0];
    this.profile_id = this.container.getAttribute('data-profile-id')
    this.channel_name = this.container.getAttribute('data-channel-name')
    this.gift_list = $(this.container).find('[data-behavior~=gift-basket-gifts]')[0]
    this.count_badge = $('[data-behavior~=gift-basket-count]')[0]
    this.channel = options.channel;
    this.handleOpenLinks();
    this.handleCloseLinks();
    this.subscribeToGiftSelectionsChannel()
    this.handleSubmitButtonClick();
    this.subtotal = $('.js-subtotal');
    this.num_gifts_words = $('.js-num-gifts-words');
    this.checkout_button = $('#js-checkout');
    App.giftBasketInstance = this;
  }

  handleOpenLinks() {
    $('body').on('click', '[data-behavior~=open-gift-basket]', (evt) => {
      evt.preventDefault();
      this.open()
    })
  }

  handleCloseLinks() {
    $(this.container).find('[data-behavior~=close-gift-basket]').on('click', (evt) => {
      evt.preventDefault();
      this.close();
    })

    $(this.overlay).on('click', (evt) => {
      evt.preventDefault();
      this.close();
    })
  }

  open() {
    $(this.overlay).show();
    $(this.container).show('slide', {direction: 'right'})
  }

  close() {
    $(this.overlay).hide();
    $(this.container).hide('slide', {direction: 'right'})
  }

  subscribeToGiftSelectionsChannel() {
    App.gift_selections_subscription = App.cable.subscriptions.create({
      channel: this.channel_name,
      profile_id: this.profile_id
      },
      {
        connected: () => {console.log('Connected to Gift Selections')},
        disconnected: () => {},
        received: (data) => {
          $(this.gift_list).html(data.gift_selections_html);
          $(this.count_badge).html(this._giftBasketCount(data.gift_basket_count));
          this.updateGiftBasketCountEmptyIndicator(data.gift_basket_count);
          $(`[data-behavior~=add-to-gift-basket-wrapper][data-gift-id=${data.updated_gift_id}]`).html(data.add_button_html);
          this.subtotal.html(data.subtotal);
          this.num_gifts_words.html(data.num_gifts_words);
          console.log(data.gift_basket_count);
          if ( data.gift_basket_count == 0 ) {
            this.checkout_button.hide();
          } else {
            this.checkout_button.show();
          }
      }
    });
  }

  _giftBasketCount(count) {
    if (count > 0) {
      return `${count}`
    } else {
      return ""
    }
  }

  updateGiftBasketCountEmptyIndicator(count) {
    if (count > 0) {
      $(this.count_badge).removeClass('empty')
    } else {
      $(this.count_badge).addClass('empty')
    }
  }

  handleSubmitButtonClick() {
    $(this.container).find('[data-behavior~=gift-basket-submit]').on('click', (evt) => {
      this.close();
      return true;
    })
  }


}
