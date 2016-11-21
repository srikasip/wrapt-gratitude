window.App.SectionedSortableQuestionList = class SectionedSortableQuestionList {
  constructor(element) {
    this.element = element;
    this.$sections = $(element).find('[data-question-list-section]')
    this.$sections.sortable({
      items: "[data-sortable-question], [data-empty-section-drop-target]",
      connectWith: '[data-question-list-section]'
    });
    this.refreshEmptySectionPlaceholderVisibility();
    this.handleSortStop();
  }

  handleSortStop() {
    $(this.element).on('sortstop', evt => {
      this.refreshEmptySectionPlaceholderVisibility();
      this.updateServer();
    })
  }

  updateServer() {
    const url = this.element.getAttribute('data-sectioned-sortable-question-list-href');
    window.sectionData = this.sectionData;
    $.ajax({
       type : "POST",
       url :  url,
       dataType: 'json',
       data : JSON.stringify(this.sectionData),
       contentType: 'application/json',
       success: () => {$(this.element).trigger('ajax:success')}
    });
  }

  get sectionData() {
    var result = {sections: []}
    this.$sections.each( (_i, section_element) => {
      var thisSectionData = {}
      const section_id = ( section_element.getAttribute('data-section-id') || "" )
      thisSectionData.id = section_id
      thisSectionData.question_ordering = this.getQuestionOrderingFromSectionElement(section_element)
      result.sections.push(thisSectionData);
    });
    return result;
  }

  getQuestionOrderingFromSectionElement(section_element) {
    var result = [];
    $(section_element).find('[data-sortable-question]').each( (_i, question_element) => {
      const id = question_element.getAttribute('data-sortable-question-id');
      result.push(id);
    } )
    return result;
  }

  refreshEmptySectionPlaceholderVisibility() {
    this.$sections.each((_i, sectionElement) => {
      const $placeholderText = $(sectionElement).find('[data-empty-section-placeholder-text]');
      const $placeholderDropTarget = $(sectionElement).find('[data-empty-section-drop-target]');
      const questionLength = $(sectionElement).find('[data-sortable-question]').length;
      if (questionLength == 0) {
        $placeholderText.show();
        $placeholderDropTarget.show();
      } else {
        $placeholderText.hide();
        $placeholderDropTarget.hide();
      }
    })
  }

}