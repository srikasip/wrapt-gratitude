App.MultipleChoiceForm = class MultipleChoiceForm {
  constructor(options = {}) {
    this.form_element = $('[data-behavior~=question-response-form]')[0];
    this.hidden_inputs_selector = $(this.form_element).find('[data-behavior~=option-id-input]');
    this.buttons_selector = $(this.form_element).find('[data-behavior~=option-button]')
    this.multipleOptionResponses = options.multipleOptionResponses;
    this.handleButtonClick();
    this.updateDisplay(true);
    this.submitting = false;
  }

  updateDisplay(init = false) {
    this.highlightSelectedButtons();
    
    if (this.multipleOptionResponses) {
      this.setNextButtonVisibilityMultipleOptionResponses()
    } else {
      this.setNextButtonVisibilitySingleOptionResponses(init)
    }

    if(!init) {
      this.setOtherTextVisibility();
    }
    
  }

  handleButtonClick() {
    this.buttons_selector.on('click', evt => {
      evt.preventDefault();
      const clicked_button = evt.currentTarget
      const option_id = clicked_button.getAttribute('data-option-id');
      this.toggleOption(option_id);
      if (!this.multipleOptionResponses) {
        this.unselectOtherOptionsIfOptionSelected(option_id)
      }
      this.updateDisplay();
      this.showOptionExplanation(option_id);
    })
  }

  toggleOption(option_id) {
    const hidden_input_selector = this.hidden_inputs_selector.filter(`[value=${option_id}]`)
    hidden_input_selector.prop('checked', !hidden_input_selector.prop('checked'))
  }

  unselectOtherOptionsIfOptionSelected(option_id) {
    const option_input_selector = this.hidden_inputs_selector.filter(`[value=${option_id}]`)
    if (option_input_selector.is(':checked')) {
      this.hidden_inputs_selector.prop('checked', false)
      option_input_selector.prop('checked', true)
    }
    // submit the form if something was selected and it's not an other button
    const selectedOtherOptionInput = $(this.hidden_inputs_selector).filter('[data-behavior~=other-option]:checked')
    if (selectedOtherOptionInput.length == 0 && option_input_selector.is(':checked')) {
      this.submitting = true;
      this.form_element.submit()
    }
  }

  highlightSelectedButtons() {
    this.buttons_selector.removeClass('selected')
    const selected_option_inputs_selector = this.hidden_inputs_selector.filter(':checked')
    selected_option_inputs_selector.each((_i, input_element) => {
      const option_id = input_element.getAttribute('value')
      this.buttons_selector.filter(`[data-option-id=${option_id}]`).addClass('selected')
    })
  }

  setNextButtonVisibilityMultipleOptionResponses() {
    const nextButton = $(this.form_element).find('[data-behavior~=next-question-button]')[0]
    const selected_option_inputs_selector = this.hidden_inputs_selector.filter(':checked')
    const nextHint = $('#js-next-question-hint-text')
    if (selected_option_inputs_selector.length > 0) {
      var disabled = false;
      $(nextHint).show();
    } else {
      var disabled = true;
      $(nextHint).hide();
    }
    $(nextButton).prop('disabled', disabled);
    
  }

  setNextButtonVisibilitySingleOptionResponses(init) {
    const nextButton = $(this.form_element).find('[data-behavior~=next-question-button]')[0]
    const selected_option_inputs_selector = this.hidden_inputs_selector.filter(':checked')
    if (init && selected_option_inputs_selector.length > 0) {
      // returning to the question via the previous button
      $(nextButton).show();
    } else if(!init && !this.submitting) {
      // they've returned to the question via the previous button
      // and they've unselected their previously selected option
      $(nextButton).show();
      if (selected_option_inputs_selector.length > 0) {
        $(nextButton).prop('disabled', false);
      } else {
       $(nextButton).prop('disabled', true);       
      }
 
    } else if(init) {
      // they're coming into the question and nothing was previously selected
      $(nextButton).hide();
    }
  }

  setOtherTextVisibility() {
    console.log('set other text visibility called');
    const otherTextWrapperSelector = $(this.form_element).find('[data-behavior~=other-text-input-wrapper]')
    const selectedOtherOptionInput = $(this.hidden_inputs_selector).filter('[data-behavior~=other-option]:checked')
    if (selectedOtherOptionInput.length > 0) {
      otherTextWrapperSelector.slideDown();
    } else {
      otherTextWrapperSelector.slideUp();
      otherTextWrapperSelector.find('[data-behavior~=other-text-input]').val('')
    }
  }

  showOptionExplanation(option_id) {
    const explanation_selector = $(this.form_element).find('[data-behavior~=option-explantion]')
    explanation_selector.hide('slow');
    const selected_option_input_selector = this.hidden_inputs_selector.filter(`[value=${option_id}]:checked`)
    if (selected_option_input_selector.length > 0) {
     // explanation_selector.filter(`[data-option-id=${option_id}]`).show('normal')     
      explanation_selector.filter(`[data-option-id=${option_id}]`).show('slow'); 
    }
 
  }


}