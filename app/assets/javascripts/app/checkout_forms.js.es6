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

App.StyledInputsBehavior = (input, container_selector) => {
  var container = $(input).parents(container_selector)
  var psuedo = $(container).find('span')
  if($(input).is(':checked')) {
    $(psuedo).addClass('checked')
  } else {
    $(psuedo).removeClass('checked')
  }
}

App.StyledCheckbox = (input) => {
  App.StyledInputsBehavior(input, '.j-wrapt-styled-checkbox')
}

App.StyledRadioButton = (input) => {
  var container_selector = '.j-wrapt-styled-radio-button'
  var inputName = $(input).attr('name')
  var inputs = $('[name="'+inputName+'"]')
  inputs.parents(container_selector).find('span').removeClass('checked')
  App.StyledInputsBehavior(input, container_selector)
}

App.SlideOnValueChecked = (input, value, checked, container_selector) => {
  var checkedCondition = checked === $(input).is(':checked') 
  if($(input).val() === value && checkedCondition) {
    $(container_selector).slideDown()
  } else {
    $(container_selector).slideUp()
  }
}

App.SelectInputByName = (object, attr) => {
  var inputName = object === '' ? attr : object+'['+attr+']'
  var input = $('[name="'+inputName+'"]')
  return input
}

App.DefaultCheckoutFormVisibilityBehavior = (object, attr, value, checked, container_selector) => {
  var input = App.SelectInputByName(object, attr)
  $(input).change(function() {
    App.SlideOnValueChecked(this, value, checked, container_selector)
  })
}

App.NoteBehavior = (object, attr, value, checked, container_selector) => {
  App.DefaultCheckoutFormVisibilityBehavior(object, attr, value, checked, container_selector)
}

App.ShowSelectAddress = (object, attr, value, checked, container_selector) => {
  App.DefaultCheckoutFormVisibilityBehavior(object, attr, value, checked, container_selector)
}

App.ShowAddressForm = (object, attr, value, checked, container_selector, new_address) => {
  var input = App.SelectInputByName(object, attr)
  $(input).change(function() {
    if(value) {
      App.SlideOnValueChecked(this, value, checked, container_selector)
    } else {
      var newAddressInput = $(new_address)
      if($(this).val() === 'ship_to_giftee') {
        $(container_selector).slideDown()
      } else if($(this).val() === 'ship_to_me') {
        if($(new_address).is(':checked')) {
          $(container_selector).slideDown()
        } else {
          $(container_selector).slideUp()
        }
      }
    }
  })
}

App.FillForm = (object, attrs, empty, input) => {
  attrs.forEach(function(attr) {
    var name = object+'['+attr+']'
    if(input && !empty) {
      var data_attr = attr.split('_')
      data_attr = data_attr[data_attr.length-1]
      $('[name="'+name+'"]').val($(input).data(data_attr))
    } else {
      $('[name="'+name+'"]').val('')
    }
  })
}

App.FillAddressFormWithSavedAddress = (object, attrs, input_selector, toggle_selector) => {
  $(input_selector).change(function() {
    if($(this).is(':checked') && $(this).val() != 'new_address') {
      App.FillForm(object, attrs, false, this)
    } else if($(this).val() === 'new_address') {
      App.FillForm(object, attrs, true, false)
    }
  })
  $(toggle_selector).change(function() {
    if($(this).val() === 'ship_to_me' && $(this).is(':checked')) {
      var checkedAddress = $(input_selector+':checked')
      App.FillForm(object, attrs, false, checkedAddress)
    } else if ($(this).val() === 'ship_to_giftee' && $(this).is(':checked')) {
      App.FillForm(object, attrs, true, false)
    }
  })
}





