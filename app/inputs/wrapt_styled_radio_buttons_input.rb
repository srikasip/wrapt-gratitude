class WraptStyledRadioButtonsInput < SimpleForm::Inputs::CollectionInput

  def input(wrapper_options)
    @collection = @options[:collection]
    template.content_tag :div, class: 'wrapt-styled-radio-buttons clearfix' do
      @collection.each do |c|
        template.concat radio_button(c)
      end
    end
  end

  def radio_button(collection_option)
    template.content_tag :label, class: 'wrapt-styled-radio-button j-wrapt-styled-radio-button' do
      template.concat content_tag :a, '', href: '#', class: (checked?(collection_option.last) ? 'checked' : ''), onClick: 'App.StyledRadioButtonA(event, this)', data: {behavior: 'wrapted_styled_input'}
      template.concat collection_option.first.html_safe
      template.concat @builder.radio_button attribute_name, collection_option.last,{onChange: 'App.StyledRadioButton(this);', checked: checked?(collection_option.last), style: 'display:none;'}
    end
  end

  def checked?(value)
    if object.send(attribute_name).nil? && @options[:nil_checked].present?
      value == @options[:nil_checked]
    else 
      object.send(attribute_name) == value
    end
  end

end