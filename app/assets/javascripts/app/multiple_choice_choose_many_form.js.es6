App.MultipleChoiceChooseManyForm = class MultipleChoiceChooseManyForm {
  constructor() {
    this.form_element = $('[data-behavior~=question-response-form]')[0];
    this.hidden_inputs_selector = $(this.form_element).find('[data-behavior~=option-id-input]');
    this.buttons_selector = $(this.form_element).find('[data-behavior~=option-button]')
    this.handleButtonClick();
    this.highlightSelectedButtons();
    this.setNextButtonVisibility();
  }

  handleButtonClick() {
    this.buttons_selector.on('click', evt => {
      evt.preventDefault();
      const clicked_button = evt.currentTarget
      const option_id = clicked_button.getAttribute('data-option-id');
      const hidden_input_selector = this.hidden_inputs_selector.filter(`[value=${option_id}]`)
      hidden_input_selector.prop('checked', !hidden_input_selector.prop('checked'))
      this.highlightSelectedButtons();
      this.setNextButtonVisibility();
    })
  }

  highlightSelectedButtons() {
    this.buttons_selector.removeClass('selected')
    const selected_option_inputs_selector = this.hidden_inputs_selector.filter(':checked')
    selected_option_inputs_selector.each((_i, input_element) => {
      const option_id = input_element.getAttribute('value')
      this.buttons_selector.filter(`[data-option-id=${option_id}]`).addClass('selected')
    })
  }

  setNextButtonVisibility() {
    const nextButton = $('[data-behavior~=next-question-button]')[0]
    const selected_option_inputs_selector = this.hidden_inputs_selector.filter(':checked')
    console.log(selected_option_inputs_selector.length)
    console.log(this.hidden_inputs_selector)
    if (selected_option_inputs_selector.length > 0) {
      $(nextButton).show();
    } else {
      $(nextButton).hide();
    }

  }


}