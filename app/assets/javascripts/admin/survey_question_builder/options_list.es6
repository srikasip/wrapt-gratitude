//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.OptionsList = class OptionsList {
  constructor(controller) {
    this.controller = controller;
    this.element = $(this.controller.element).find('[data-option-list]')[0]
    this.options = {};
    this.addExistingOptions();
    // this.render();
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

  appendOptionRow(html) {
    console.log(this.element.innerHtml)
    console.log(html)
    $(this.element).append(html);
  }


}