//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.OptionsList = class OptionsList {
  constructor(controller) {
    this.controller = controller;
    this.element = $(this.controller.element).find('[data-option-list]')[0]
  }

  appendOptionRow(html) {
    $(this.element).append(html);
  }


}