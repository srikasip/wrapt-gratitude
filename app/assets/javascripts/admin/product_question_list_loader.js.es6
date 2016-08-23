App.ProductQuestionListLoader = class ProductQuestionListLoader {
  constructor(btnElement) {
    this.btnElement = btnElement;
    this.productRowElement = $(this.btnElement).parents('tr[data-product-row]')[0];
    this.registerClick();
  }

  registerClick() {
    $(this.btnElement).click( evt => {
      evt.preventDefault();
      const url = $(evt.currentTarget).attr('href');
      $.get( url, ( html => {
        $(html).hide().insertAfter(this.productRowElement).show('normal');
      } ), 'html');

    } )
  }

}