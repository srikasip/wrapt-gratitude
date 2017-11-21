class WraptStyledCheckboxInput < SimpleForm::Inputs::BooleanInput

  def input(wrapper_options)
    template.content_tag :label, class: 'wrapt-styled-checkbox j-wrapt-styled-checkbox' do
      template.concat content_tag :a, '', href: '#', class: [(checked? ? 'checked' : ''), (has_errors? ? 'error' : '')], onClick: 'App.StyledCheckboxA(event, this)', data: {behavior: 'wrapted_styled_input'}
      template.concat @options[:label]
      template.concat @builder.check_box attribute_name, {onChange: 'App.StyledCheckbox(this);', checked: checked?, style: 'display:none;'}, checked_value, unchecked_value 
    end
  end

  def checked?
    if @options[:input_html].present? && @options[:input_html][:checked]
      if has_errors?
        object.send(attribute_name) == (checked_value == '1')
      else
        @options[:input_html][:checked] == true
      end
    else
      object.send(attribute_name) == (checked_value == '1')
    end
  end

  def label
    false
  end

end