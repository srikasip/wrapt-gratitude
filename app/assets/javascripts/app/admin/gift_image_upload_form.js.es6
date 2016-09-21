//= require ./namespace

App.Admin.ImageUploadForm = class ImageUploadForm {
  constructor(formElement) {
    this.formElement = formElement
    this.inputElement = $(formElement).find('[data-image-upload-input]')[0]
    this.submitOnChange();
  }

  submitOnChange() {
    $(this.inputElement).on('change', (evt) => this.formElement.submit())
  }

}