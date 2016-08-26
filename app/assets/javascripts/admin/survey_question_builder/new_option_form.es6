//= require ./namespace

// Top-level controller for the whole builder
window.App.Admin.SurveyQuestionBuilder.NewOptionForm = class NewOptionForm {
  constructor(controller) {
    this.controller = controller;
    this.element = $(this.controller.element).find('[data-new-option-form]');
    this.newOptionTextInput = $(this.element).find('input[data-new-option-text]')[0]
    this.handleSubmitSuccess();
  }

  handleSubmitSuccess() {
    $(this.element).on('ajax:success', (evt, data) => {
      this.controller.optionsList.appendOptionRow(data);
      this.reset();
    });
  }

  updateServer() {
    // TODO
  }

  reset() {
    $(this.newOptionTextInput).val('');
  }
}