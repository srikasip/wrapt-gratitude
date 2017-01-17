// submits the form to save any changes and then follows link to prev questions

App.PrevButtonBehavior = class PrevButtonBehavior {
  constructor(options = {}) {
    this.form_element = $('[data-behavior~=question-response-form]');
    this.prev_link = $('[data-behavior~=prev-question-button]');
    this.text_field = $(this.form_element).find('[data-behavior~=text-response]');
    this.range_field = $(this.form_element).find('[data-behavior~=range-response]')
    this.multi_field = $(this.form_element).find('[data-behavior~=option-id-input]');
    this.findActiveField()
    this.prevLinkClick();
  }

  findActiveField() {
    if(this.text_field.length > 0) {
      this.active_field = this.text_field;
    } else if(this.range_field.length > 0) {
      this.active_field = this.range_field;
    } else if(this.multi_field.length > 0) {
      this.active_field = this.multi_field;
    }
  }

  hasActiveVal() {
    if(this.active_field == this.text_field) {
      return this.text_field.val();
    } else if(this.active_field == this.range_field) {
      return true
    } else if(this.active_field == this.multi_field) {
      return this.multi_field.filter(':checked').length > 0
    }
  }

  prevLinkClick() {
    $(this.prev_link).on('click', e => {
      e.preventDefault();
      $(this.form_element).submit({viaAjax: true}, e => {
        e.preventDefault();
        this.submitForm(e);
      });
      $(this.form_element).submit();
    })
  }

  submitFormViaAjax() {
    $.ajax({
      url: $(this.form_element).attr('action'), 
      type: $(this.form_element).attr('method'), 
      dataType: 'json', 
      data: $(this.form_element).serialize(),
      success: () => {
        window.location.href = $(this.prev_link).attr('href');
      }
    })
  }

  submitForm(e) {
    if(e.data.viaAjax) {
      if(this.hasActiveVal()) {
        this.submitFormViaAjax();
      } else {
        window.location.href = this.prev_link.attr('href');
      }
    }
  }
}