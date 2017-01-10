App.MultipleChoiceChooseOneForm = class MultipleChoiceChooseOneForm {
  constructor() {
    this.form_element = $('[data-behavior~=question-response-form]')[0];
    this.hidden_input_element = $(this.form_element).find('[data-behavior~=option-id-input-field]')[0];
    this.button_selector = $(this.form_element).find('[data-behavior~=option-button]')
    this.handleButtonClick();
    this.highlightSelectedButton();
    this.setNextButtonInitialVisibility();
  }

  handleButtonClick() {
    this.button_selector.on('click', evt => {
      console.log(evt.currentTarget);
      const selected_button = evt.currentTarget
      const option_id = selected_button.getAttribute('data-option-id');
      this.hidden_input_element.setAttribute('value', option_id)
      this.highlightSelectedButton();
      this.form_element.submit();
    })
  }

  highlightSelectedButton() {
    console.log(this.hidden_input_element);
    console.log(this.button_selector.toArray());
    this.button_selector.removeClass('selected');
    const selected_option_id = this.hidden_input_element.getAttribute('value')
    if (selected_option_id) {
      console.log(`[data-option-id=${selected_option_id}]`);
      this.button_selector.filter(`[data-option-id=${selected_option_id}]`).addClass('selected');
    }
  }

  setNextButtonInitialVisibility() {
    const nextButton = $('[data-behavior~=next-question-button]')[0]
    const selected_option_id = this.hidden_input_element.getAttribute('value')
    if (selected_option_id) {
      $(nextButton).show();
    } else {
      $(nextButton).hide();
    }

  }


}