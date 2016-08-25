//= require ./namespace

// this class represents a row in the list for an option with edit and delete buttons
window.App.Admin.SurveyQuestionBuilder.OptionRow = class OptionRow {
  constructor(optionList, option) {
    this.optionList = optionList;
    this.option = option;
    this.handleEditClick();
  }

}