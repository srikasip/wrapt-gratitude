App.GiftBasket = class GiftBasket {
  constructor() {
    this.container = $('[data-behavior~=gift-basket-container]')[0];
    this.overlay = $('[data-behavior~=gift-basket-overlay]')[0];
    this.profile_id = this.container.getAttribute('data-profile-id')
    this.gift_list = $(this.container).find('[data-behavior~=gift-basket-gifts]')[0]
    this.handleOpenLinks();
    this.handleCloseLinks();
    this.handleRemoveLinks();
    this.subscribeToGiftSelectionsChannel()
    App.giftBasketInstance = this;
  }

  handleOpenLinks() {
    $(this.container).find('[data-behavior~=open-gift-basket]').on('click', (evt) => {
      evt.preventDefault();
      this.open()
    })
  }

  handleCloseLinks() {
    $(this.container).find('[data-behavior~=close-gift-basket]').on('click', (evt) => {
      evt.preventDefault();
      this.close()
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
      channel: "GiftSelectionsChannel",
      profile_id: this.profile_id
      },
      {
        connected: () => {console.log('Connected to Gift Selections')},
        disconnected: () => {},
        received: (data) => {
          $(this.gift_list).html(data.gift_selections_html);
          // TODO update Badge count
      }
    });
  }


}