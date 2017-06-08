class WraptRadioAsButtonsInput < SimpleForm::Inputs::CollectionInput

  def input(wrapper_options)
    @collection = @options[:collection]
    template.content_tag(:div) do
      @collection.each do |c|
        template.concat button(c)
      end
    end
  end

  def button(collection_option)
    label_key = "#{attribute_name.to_s}_#{collection_option.first.to_s}".to_sym
    @builder.label label_key, class: 'j-radio-as-button__label btn-multiple-choice-option' do
      template.concat collection_option.last
      template.concat @builder.radio_button attribute_name, collection_option.first, class: 'j-radio-as-button', style: 'display:none;'
    end
  end

end