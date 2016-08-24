App.ProductQuestionListLoader = class ProductQuestionListLoader {
  constructor(viewBtnElement) {
    this.viewBtnElement = viewBtnElement;
    this.hideBtnElement = $(viewBtnElement).siblings('[data-hide-questions-btn]')[0];
    this.productRowElement = $(this.viewBtnElement).parents('tr[data-product-row]')[0];
    this.productId = $(this.productRowElement).data('product-row');
    this._registerViewBtnClick();
    this._registerHideBtnClick();
  }

  _registerViewBtnClick() {
    $(this.viewBtnElement).click( evt => {
      evt.preventDefault();
      const url = $(evt.currentTarget).attr('href');
      $.get( url, html => {this._afterFetchQuestionList(html)}, 'html');
    } )
  }

  _afterFetchQuestionList(html) {
    $(html).hide().insertAfter(this.productRowElement).show('normal');
    this._enableHideBtn();
  }

  _registerHideBtnClick() {
    $(this.hideBtnElement).click( evt => {
      evt.preventDefault();
      $(`[data-product-question-row-for-product="${this.productId}"]`).hide('normal', rowElement => {
        $(rowElement).remove();
        this._enableViewBtn();
      });
      
    })
  }

  _enableHideBtn() {
    $(this.viewBtnElement).hide();
    $(this.hideBtnElement).show();
  }

  _enableViewBtn() {
    $(this.viewBtnElement).show();
    $(this.hideBtnElement).hide();
  }

}