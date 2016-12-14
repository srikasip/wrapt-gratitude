//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.EditOptionLink = class EditOptionLink {
  constructor(element) {
    this.element = element;
    this.handleAjaxSuccess();
  }

  handleAjaxSuccess() {
    $(this.element).on("ajax:success", (evt, data) => {
      console.log(data)
      $(this.element).parents('[data-option-row]').html(data);
    })
  }

}