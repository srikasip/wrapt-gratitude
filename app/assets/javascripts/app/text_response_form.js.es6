App.TextResponseForm = class TextResponseForm {
  constructor(options = {}) {
    console.log('text response form loaded');
    this.input = $('[data-behavior~=text-response]');
    this.next_btn = $('[data-behavior~=next-question-button]');
    this.next_hint = $('#js-next-question-hint-text');
    this.updateInput();
    this.inputChange();
    this.inputKeyup();
  }

  inputChange() {
    $(this.input).change(() => {
      this.updateInput();
    });
  }

  inputKeyup() {
    $(this.input).keyup(() => {
      if($(this.input).val().length == 0) {
        this.updateButton(true);
      } else {
        this.updateButton(false);
      }
    })
  }

  updateInput() {
    if($(this.input).val()) {
      this.updateButton(false);
    } else {
      this.updateButton(true);
    }
  }

  updateButton(disabled) {
    $(this.next_btn).prop('disabled', disabled);
    if(disabled) {
      $(this.next_hint).hide();
    } else {
      $(this.next_hint).show();
    }
  }
}