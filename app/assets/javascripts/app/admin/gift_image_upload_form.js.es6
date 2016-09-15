//= require ./namespace

App.Admin.GiftImageUploadForm = class GiftImageUploadForm {
  constructor(formElement) {
    this.formElement = formElement
    this.inputElement = $(formElement).find('[data-gift-image-upload-input]')[0]
    this.submitOnChange();
  }

  submitOnChange() {
    $(this.inputElement).on('change', (evt) => this.formElement.submit())
  }

}