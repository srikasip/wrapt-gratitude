//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.EditOptionImageLink = class EditOptionImageLink {
  constructor(element) {
    this.element = element;
    this.handleAjaxSuccess();
  }

  handleAjaxSuccess() {
    $(this.element).on("ajax:success", (evt, data) => {
      $(this.element).parents('[data-option-row]').html(data);
    })
  }

}