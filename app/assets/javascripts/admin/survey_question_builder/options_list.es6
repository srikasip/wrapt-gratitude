//= require ./namespace

window.App.Admin.SurveyQuestionBuilder.OptionsList = class OptionsList {
  constructor(controller) {
    this.controller = controller;
    this.element = $(this.controller.element).find('[data-option-list]')[0]
    // this.render();
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