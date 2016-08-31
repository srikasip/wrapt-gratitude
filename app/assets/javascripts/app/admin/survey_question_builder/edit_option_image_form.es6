//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.EditOptionImageForm = class EditOptionImageForm {
  constructor(element) {
    this.formElement = element;
    this.imageInputElement = $(this.formElement).find('[data-survey-option-image-input]')[0]
    this.optionRowElement = $(this.formElement).parent()[0]
    this.deleteButtonElement = $(this.formElement).find('[data-delete-survey-option-image-link]')[0]
    this.cancelButtonElement = $(this.formElement).find('[data-cancel-survey-option-image-link]')[0]
    this.initializeJqueryFileUpload();
    this.handleDeleteAjaxSuccess();
    this.handleCancelAjaxSuccess();
  }

  initializeJqueryFileUpload() {
    $(this.imageInputElement).fileupload({
      dataType: 'html',
      done: (evt, data) => {
        $(this.optionRowElement).replaceWith(data.response().result);
      }
    })
  }

  handleDeleteAjaxSuccess() {
    $(this.deleteButtonElement).on('ajax:success', (evt, data) => {
      $(this.optionRowElement).replaceWith(data);
    })
  }

  handleCancelAjaxSuccess() {
    // console.log("Cancel", this.cancelButtonElement)
    $(this.cancelButtonElement).on('ajax:success', (evt, data) => {
      $(this.optionRowElement).replaceWith(data);
    })
  }

}