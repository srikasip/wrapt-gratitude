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
  var psuedo = $(container).find('a')
  if($(input).is(':checked')) {
    $(psuedo).addClass('checked')
  } else {
    $(psuedo).removeClass('checked')
  }
}

App.StyledInputsABehavior = (ele, container_selector) => {
  var container = $(ele).parents(container_selector)
  var input = $(container).find('input')
  if($(input).is(':checked')) {
    $(input).prop('checked', false)
  } else {
    $(input).prop('checked', true)
  }
  $(input).trigger('change')
}

App.StyledCheckbox = (input) => {
  App.StyledInputsBehavior(input, '.j-wrapt-styled-checkbox')
}

App.StyledCheckboxA = (event, ele) => {
  event.preventDefault()
  App.StyledInputsABehavior(ele, '.j-wrapt-styled-checkbox')
}

App.StyledRadioButton = (input) => {
  var container_selector = '.j-wrapt-styled-radio-button'
  var inputName = $(input).attr('name')
  var inputs = $('[name="'+inputName+'"]')
  inputs.parents(container_selector).find('a').removeClass('checked')
  App.StyledInputsBehavior(input, container_selector)
}

App.StyledRadioButtonA = (event, ele) => {
  event.preventDefault()
  App.StyledInputsABehavior(ele, '.j-wrapt-styled-radio-button')
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

App.ShowBillingAddress = (object, attr, value, checked, container_selector) => {
  App.DefaultCheckoutFormVisibilityBehavior(object, attr, value, checked, container_selector)
  var input = App.SelectInputByName(object, attr)
  var zip_input = $('[name="address-zip"]')
  input.change(function() {
    if($(this).is(':checked')) {
      $(zip_input).val($(this).data('zip'))
    } else {
      $(zip_input).val('')
    }
  })
}

App.ShowAddressForm = (object, attr, value, checked, container_selector, new_address) => {
  new_address = '#'+object+'_address_id_'+new_address
  var input = App.SelectInputByName(object, attr)
  $(input).change(function() {
    if(value) {
      App.SlideOnValueChecked(this, value, checked, container_selector)
    } else {
      if($(this).val() === 'ship_to_giftee') {
        $(container_selector).slideDown()
      } else if($(this).val() === 'ship_to_customer') {
        if($(new_address).is(':checked')) {
          $(container_selector).slideDown()
        } else {
          $(container_selector).slideUp()
        }
      }
    }
  })
}

App.ClearInputs = (object, attrs) => {
  attrs.forEach(function(attr) {
    var input = '[name="'+object+'['+attr+']"]'
    $(input).val('')
  })
}

App.ClearForm = (object, attrs, toggle_selector, value) => {
  $(toggle_selector).change(function() {
    if(value) {
      if($(this).val() === value && $(this).is(':checked')) {
        App.ClearInputs(object, attrs)
      }
    } else {
      App.ClearInputs(object, attrs)
    }
    
  })
}





