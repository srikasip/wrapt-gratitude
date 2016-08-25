//= require ./namespace

// Top-level controller for the whole builder
window.App.Admin.SurveyQuestionBuilder.NewOptionForm = class NewOptionForm {
  constructor(controller) {
    this.controller = controller;
    this.element = $(this.controller.element).find('[data-new-option-form]');
    this.newOptionTextInput = $(this.element).find('input[data-new-option-text]')[0]
    this.handleSubmit();
  }

  handleSubmit() {
    $(this.element).on('submit', evt => {
      evt.preventDefault();
      this.updateServer();
      const optionText = $(this.newOptionTextInput).val();
      this.controller.optionsList.addOption({text: optionText});
      this.controller.optionsList.render();
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