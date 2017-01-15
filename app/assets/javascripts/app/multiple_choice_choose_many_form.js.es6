App.MultipleChoiceChooseManyForm = class MultipleChoiceChooseManyForm {
  constructor() {
    this.form_element = $('[data-behavior~=question-response-form]')[0];
    this.hidden_inputs_selector = $(this.form_element).find('[data-behavior~=option-id-input]');
    this.buttons_selector = $(this.form_element).find('[data-behavior~=option-button]')
    this.handleButtonClick();
    this.updateDisplay();
  }

  updateDisplay() {
    this.highlightSelectedButtons();
    this.setNextButtonVisibility();
    this.setOtherTextVisibility();
  }

  handleButtonClick() {
    this.buttons_selector.on('click', evt => {
      evt.preventDefault();
      const clicked_button = evt.currentTarget
      const option_id = clicked_button.getAttribute('data-option-id');
      const hidden_input_selector = this.hidden_inputs_selector.filter(`[value=${option_id}]`)
      hidden_input_selector.prop('checked', !hidden_input_selector.prop('checked'))
      this.updateDisplay();
      this.showOptionExplanation(option_id);
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
    const nextButton = $(this.form_element).find('[data-behavior~=next-question-button]')[0]
    const selected_option_inputs_selector = this.hidden_inputs_selector.filter(':checked')
    const nextHint = $('#js-next-question-hint-text')
    if (selected_option_inputs_selector.length > 0) {
      $(nextButton).show();
      $(nextHint).show();
    } else {
      $(nextButton).hide();
      $(nextHint).hide();
    }
  }

  setOtherTextVisibility() {
    const otherTextWrapperSelector = $(this.form_element).find('[data-behavior~=other-text-input-wrapper]')

    const selectedOtherOptionInput = $(this.hidden_inputs_selector).filter('[data-behavior~=other-option]:checked')
    if (selectedOtherOptionInput.length > 0) {
      otherTextWrapperSelector.show()
    } else {
      otherTextWrapperSelector.hide()
      otherTextWrapperSelector.find('[data-behavior~=other-text-input]').val('')
    }
  }

  showOptionExplanation(option_id) {
    const explanation_selector = $(this.form_element).find('[data-behavior~=option-explantion]')
    explanation_selector.hide('normal');
    const selected_option_input_selector = this.hidden_inputs_selector.filter(`[value=${option_id}]:checked`)
    if (selected_option_input_selector.length > 0) {
     explanation_selector.filter(`[data-option-id=${option_id}]`).show('normal')     
    }
 
  }


}