//= require ./namespace

App.Admin.ConditionalQuestionDisplay.Controller = class Controller {
  constructor() {
    this.form = $('[data-behavior~=conditional-question-display-form]')
    this.initializeQuestions()
    this.refreshConditionalQuestionVisibility()
    this.handleOptionChange()
  }

  initializeQuestions() {
    this.questions_by_id = {}
    this.conditional_questions = []
    $('[data-behavior~=survey_question]').each( (_i, element) =>{
      const question = new App.Admin.ConditionalQuestionDisplay.Question(element, this)
      this.questions_by_id[question.question_id] = question
      if (question.conditional_display) {
        this.conditional_questions.push(question);
      }
    })
    console.log("Questions By ID", this.questions_by_id)
    console.log("Conditional Questions", this.conditional_questions)
  }

  refreshConditionalQuestionVisibility() {
    this.conditional_questions.forEach(question => {
      question.refreshDisplay()
    })
  }

  // this could be made more efficient by only listening to the options that matter to conditional questions
  handleOptionChange() {
    console.log('listening', this.form.find('[data-behavior~=survey_question_option_input]'))
    this.form.on('click', '[data-behavior~=survey_question_option_input]', evt => {
      console.log('refreshing!')
      this.refreshConditionalQuestionVisibility();
    })
  }

}