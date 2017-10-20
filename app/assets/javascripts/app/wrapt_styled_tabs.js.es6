App.WraptStyledTabs = (tabs_selector, tab_selector) => {
  $(tabs_selector).find('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    $(e.target).parents(tabs_selector).find(tab_selector).removeClass('active')
    $(e.target).parents(tab_selector).addClass('active')
  })
}