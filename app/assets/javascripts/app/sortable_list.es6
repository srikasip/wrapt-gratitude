window.App.SortableList = class SortableList {
  constructor(element) {
    this.element = element;
    $(element).sortable();
    this.updateServerOnSortStop();
  }

  updateServerOnSortStop() {
    $(this.element).on('sortstop', evt => {
      const url = this.element.getAttribute('data-sortable-list-href');
      console.log(this.orderingData);
      $.post(url, this.orderingData);
    })
  }

  get orderingData() {
    var result = {survey_question_ordering: {ordering: []}};
    $(this.element).children('[data-question]').each( (_i, question_element) => {
      const id = question_element.getAttribute('data-question-id');
      result.survey_question_ordering.ordering.push(id);
    } )
    return result;
  }
}