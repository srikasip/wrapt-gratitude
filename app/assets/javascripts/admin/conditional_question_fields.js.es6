//= require ./namespace

App.Admin.ConditionalQuestionFields = class ConditionalQuestionFields {
  constructor() {
    this.display_toggle_input = $('[data-behavior~=toggle-conditional-question-fields]')[0];
    this.form_fields = $('[data-behavior~=conditional-question-fields]')[0]
    this.question_id_input = $('[data-behavior~=conditional-question-id-input]')[0]
    this.options_container = $('[data-behavior~=conditional-question-options-container]')[0]

    this.showFieldsIfCheckedInitially();
    this.handleDisplayToggleChange();
    this.loadOptionFieldsOnQuestionChange();
  }

  showFieldsIfCheckedInitially() {
    if (this.display_toggle_input.checked) {
      $(this.form_fields).show();
    }
  }

  handleDisplayToggleChange() {
    $(this.display_toggle_input).on('change', evt => {
      $(this.form_fields).toggle('normal');
    })
  }

  loadOptionFieldsOnQuestionChange() {
    $(this.question_id_input).on('change', evt => {
      const question_id = $(this.question_id_input).val();
      if (question_id) {
        const url_base = $(this.options_container).attr('data-conditional-question-options-url-base')
        console.log(this.options_container)
        console.log($(this.options_container).attr('data-conditional-question-options-url-base'))
        const url = `${url_base}/${question_id}`
        $(this.options_container).load(url);
      } else {
        $(this.options_container).html("");
      }

    })
  }

}