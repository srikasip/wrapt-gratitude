//= require ./namespace

App.Admin.TraitResponseImpactFieldsLoader = class TraitResponseImpactFieldsLoader {
  constructor(form_element) {
    this.form_element = form_element
    this.facet_select = $(this.form_element).find('[data-behavior~=facet-select]')[0]
    this.fields_container = $(this.form_element).find('[data-behavior~=trait-response-impact-fields-container]')[0]
    this.handle_facet_select_change();
  }

  handle_facet_select_change() {
    $(this.facet_select).on('change', evt => {
      const base_url = this.fields_container.getAttribute('data-trait-response-impact-fields-url')
      const facet_id = $(evt.currentTarget).val()
      const full_url = `${base_url}?facet_id=${facet_id}`
      $(this.fields_container).load(full_url);
    })
  }

}