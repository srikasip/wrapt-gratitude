//= require ./namespace

// Top-level controller for the whole builder
window.App.Admin.SurveyQuestionBuilder.EditOptionForm = class EditOptionForm {
  constructor(optionsList, option) {
    this.controller = controller;
    this.option = option;
  }

  reset() {
    $(this.newOptionTextInput).val('');
  }
}