//= require ./namespace

App.Admin.GiftQuestionListLoader = class GiftQuestionListLoader {
  constructor(viewBtnElement) {
    this.viewBtnElement = viewBtnElement;
    this.hideBtnElement = $(viewBtnElement).siblings('[data-hide-questions-btn]')[0];
    this.giftRowElement = $(this.viewBtnElement).parents('tr[data-gift-row]')[0];
    this.giftId = $(this.giftRowElement).data('gift-row');
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
    $(html).hide().insertAfter(this.giftRowElement).show('normal');
    this._enableHideBtn();
  }

  _registerHideBtnClick() {
    $(this.hideBtnElement).click( evt => {
      evt.preventDefault();
      $(`[data-gift-question-impact-row-for-gift="${this.giftId}"]`).hide('normal', rowElement => {
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