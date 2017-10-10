class WraptStyledCheckboxInput < SimpleForm::Inputs::BooleanInput

  def input(wrapper_options)
    template.content_tag :label, class: 'wrapt-styled-checkbox j-wrapt-styled-checkbox' do
      template.concat content_tag :a, '', href: '#', class: (checked? ? 'checked' : ''), onClick: 'App.StyledCheckboxA(event, this)'
      template.concat @options[:label]
      template.concat @builder.check_box attribute_name, {onChange: 'App.StyledCheckbox(this);', checked: checked?, style: 'display:none;'}, checked_value, unchecked_value 
    end
  end

  def checked?
    if checked_value.present?
      cv = checked_value == 1 
    else
      cv = true
    end
    object.send(attribute_name) == cv
  end

  def label
    false
  end

end