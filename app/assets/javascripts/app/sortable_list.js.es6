window.App.SortableList = class SortableList {
  constructor(element) {
    this.element = element;
    $(element).sortable({
      items: "[data-sortable-item]"
    });
    this.updateServerOnSortStop();
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
}