//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.OptionsList = class OptionsList {
  constructor(controller) {
    this.controller = controller;
    this.element = $(this.controller.element).find('[data-option-list]')[0]
    this.options = {};
    this.addExistingOptions();
    this.render();
    this.handleDeleteButtons();
  }

  addExistingOptions() {
    $(this.controller.element).find('[data-option]').each((_i, optionElement) => {
      const optionData = {text: $(optionElement).data('option-text'), id: $(optionElement).data('option-id') };
      this.addOption(optionData);
      $(optionElement).remove();
    })
  }

  addOption(optionData) {
    const option = new App.Admin.SurveyQuestionBuilder.Option(optionData);
    this.options[optionData.id] = option;
  }

  render() {
    $(this.element).html('');
    for (var key in this.options) {
      if (this.options.hasOwnProperty(key)) {
        const option = this.options[key];
        $(this.element).append(option.toHtml());
      }
      
    }
  }

  handleDeleteButtons() {
    $(this.element).on("click", '[data-delete-option]', evt => {
      evt.preventDefault();
      // TODO delete on server
      console.log(evt.currentTarget);
      const optionId = evt.currentTarget.getAttribute('data-delete-option');
      $(this.element).find(`[data-option-row][data-option-id=${optionId}]`).remove();
      delete this.options[optionId];
    })
  }


}