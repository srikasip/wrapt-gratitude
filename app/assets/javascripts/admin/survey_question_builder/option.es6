//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.Option = class Option {
  constructor(data) {
    this.text = data.text;
    this.id = data.id;
    this.hi = "hi I'm an option"
  }

  toHtml() {
    return HandlebarsTemplates['admin/survey_question_builder/option']({option: this});
  }


}