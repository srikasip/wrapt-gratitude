//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.EditOptionImageForm = class EditOptionImageForm {
  constructor(element) {
    this.element = element;
    this.optionRowElement = $(this.element).parent()[0]
    this.handleImageChange();
    this.handleAjaxSuccess();
  }

  handleImageChange() {
    $(this.element).find('[data-survey-option-image-input]').on('change', (evt) => {
      $(this.element).submit();
    })
  }

  handleAjaxSuccess() {
    $(this.element).on('ajax:success', (evt, data) => {
      $(this.optionRowElement).replaceWith(data);
    });
  }
}