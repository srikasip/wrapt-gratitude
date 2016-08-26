//= require ./namespace

// Top-level controller for the whole builder
window.App.Admin.SurveyQuestionBuilder.Controller = class Controller {
  constructor(element) {
    this.element = element;
    this.optionsList = new App.Admin.SurveyQuestionBuilder.OptionsList(this);
    this.newOptionForm = new App.Admin.SurveyQuestionBuilder.NewOptionForm(this);
    this.handleAjaxErrors()
  }

  handleAjaxErrors() {
    $(this.element).on('ajax:error', (evt, status, error) => {
      console.log(status);
      console.log(error);
      alert("Sorry, an error occurred. Please refresh the page;")
    });
  }
}