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
    // this.updateServerOnSortStop();
  }

  updateServerOnSortStop() {
    $(this.element).on('sortstop', evt => {
      const url = this.element.getAttribute('data-sortable-list-href');
      $.post(url, this.orderingData, () => {$(this.element).trigger('ajax:success')});
    })
  }

  get orderingData() {
    var result = {ordering: []};
    $(this.element).children('[data-sortable-item]').each( (_i, question_element) => {
      const id = question_element.getAttribute('data-sortable-item-id');
      result.ordering.push(id);
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

  handleSortStop() {
    $(this.element).on('sortstop', evt => {
      this.refreshEmptySectionPlaceholderVisibility()
    })
  }

}