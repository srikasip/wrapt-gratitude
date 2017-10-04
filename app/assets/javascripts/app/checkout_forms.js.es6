App.RadioToggle = (input) => {
  var container = $(input).parents('.j-wrapt-radio-toggle')
  var inputs = container.find('input')
  inputs.each(function(i) {
    if($(this).is(':checked')) {
      $(this).parents('label').addClass('selected')
    } else {
      $(this).parents('label').removeClass('selected')
    }
  })
}

App.StyledCheckbox = (input) => {
  var container = $(input).parents('.j-wrapt-styled-checkbox')
  var psuedo = $(container).find('span')
  if($(input).is(':checked')) {
    $(psuedo).addClass('checked')
  } else {
    $(psuedo).removeClass('checked')
  }
}

App.NoteBehavior = (object, attr, value, container_selector, checked) => {
  var inputName = object+'['+attr+']'
  var input = $('[name="'+inputName+'"]')
  $(input).change(function() {
    var checkedCondition = checked === $(this).is(':checked') 
    if($(this).val() === value && checkedCondition) {
      $(container_selector).slideDown()
    } else {
      $(container_selector).slideUp()
    }
  })
}