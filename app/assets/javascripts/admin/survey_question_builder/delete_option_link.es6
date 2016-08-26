//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.DeleteOptionLink = class DeleteOptionLink {
  constructor(element) {
    this.element = element;
    this.handleAjaxSuccess();
  }

  handleAjaxSuccess() {
    $(this.element).on("ajax:success", evt => {
      console.log($(this.element).parents('[data-option-row]'))
      $(this.element).parents('[data-option-row]').remove()
    })
  }

}