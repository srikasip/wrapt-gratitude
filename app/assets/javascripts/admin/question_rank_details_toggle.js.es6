//= require ./namespace

App.Admin.QuestionRankDetailsToggle = class QuestionRankDetailsToggle {
  constructor(element) {
    this.element = element;
    const questionId = this.element.getAttribute('data-question-id');
    this.detailsElement = $(`[data-question-rank-details][data-question-id="${questionId}"]`)[0]
    this.visible = false;
    this.handleClick();
  }

  handleClick() {
    $(this.element).on('click', (evt) => {
      evt.preventDefault(); 
      $(this.detailsElement).toggle('normal')
      this.visible = !this.visible
      this.setButtonText()
    })
  }

  setButtonText() {
    if (this.visible) {
      $(this.element).text('Hide Details')
    } else {
      $(this.element).text('Show Details')
    }
  }

}