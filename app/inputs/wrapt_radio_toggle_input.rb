class WraptRadioToggleInput < SimpleForm::Inputs::CollectionInput

  def input(wrapper_options)
    @collection = @options[:collection]
    template.content_tag :div, class: 'j-wrapt-radio-toggle' do
      @collection.each do |c|
        template.concat button(c)
      end
    end
  end

  def button(collection_option)
    label_key = "#{attribute_name.to_s}_#{collection_option.last.to_s}".to_sym
    label_class = selected?(collection_option) ? 'selected' : ''
    @builder.label label_key, class: label_class, tabindex: '0', onkeypress: 'App.RadioToggleLabel(this, event);' do
      template.concat collection_option.first
      template.concat @builder.radio_button attribute_name, collection_option.last, style: 'display:none;', onChange: 'App.RadioToggle(this);'
    end 
  end

  def selected?(collection_option)
    object.send(attribute_name) == collection_option.last
  end

end