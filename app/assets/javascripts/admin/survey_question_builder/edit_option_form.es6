//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.EditOptionForm = class EditOptionForm {
  constructor(element) {
    this.element = element;
    this.handleAjaxSuccess();
  }

  handleAjaxSuccess() {
    $(this.element).on('ajax:success', (evt, data) => {
      $(this.element).parent().replaceWith(data);
    });
  }
}