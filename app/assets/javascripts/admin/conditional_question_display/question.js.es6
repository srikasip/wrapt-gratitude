//= require ./namespace

App.Admin.ConditionalQuestionDisplay.Question = class Question {
  constructor(element, controller) {
    this.element = element;
    this.controller = controller
    this.question_id = element.getAttribute('data-question-id')
    this.conditional_display = element.getAttribute('data-conditional-display') == 'true'
    this.conditional_question_id = element.getAttribute('data-conditional-question-id')
    this.conditional_question_option_ids = $.parseJSON(element.getAttribute('data-conditional-question-option-ids'))
  }

  displayConditionsMet() {
    var result = false;
    this.conditional_question_option_ids.forEach(id => {
      const input_selector = `input[data-behavior~=survey_question_option_input][value=${id}]:checked`
      console.log(input_selector, $(this.controller.form).find(input_selector).length);
      if ($(this.controller.form).find(input_selector).length > 0) {
        result = true;
        // this could be made more efficient by short-circuiting the loop here
      }
    })
    return result;
  }

  refreshDisplay() {
    if (this.displayConditionsMet()) {
      this.show()
    } else {
      console.log("Hiding", this.element);
      this.hide()
    }
  }

  show() { $(this.element).show() }
  hide() { $(this.element).hide() }

}