//= require ./namespace

App.Admin.ConditionalQuestionFields = class ConditionalQuestionFields {
  constructor() {
    this.display_toggle_input = $('[data-behavior~=toggle-conditional-question-fields]')[0];
    this.form_fields = $('[data-behavior~=conditional-question-fields]')

    if (this.display_toggle_input.checked) {
      $(this.form_fields).show();
    }
    this.handleDisplayToggleChange();
  }

  handleDisplayToggleChange() {
    $(this.display_toggle_input).on('change', evt => {
      $(this.form_fields).toggle('normal');
    })
  }

}