//= require ./namespace

// Top-level controller for the whole builder
window.App.Admin.SurveyQuestionBuilder.Controller = class Controller {
  constructor(element) {
    this.element = element;
    this.optionsList = new App.Admin.SurveyQuestionBuilder.OptionsList(this);
    this.newOptionForm = new App.Admin.SurveyQuestionBuilder.NewOptionForm(this);
    this.handleAjaxErrors();
    this.handleAjaxSuccess();
  }

  handleAjaxErrors() {
    $(this.element).on('ajax:error', (evt, status, error) => {
      console.log(status);
      console.log(error);
      alert("Sorry, an error occurred. Please refresh the page;")
    });
  }

  // note that other handlers might do something too
  handleAjaxSuccess() {
    $(this.element).on('ajax:success', evt => {
      const previewElement = $(this.element).find('[data-question-preview]')[0]
      const href = previewElement.getAttribute('data-question-preview-href')
      $.get(href, data => {
        $(previewElement).replaceWith(data);
      }, 'html')
    })
  }
}