class WraptRangeInput < SimpleForm::Inputs::Base

  def input(wrapper_options)
    template.content_tag :div, class: 'wrapt-range__container' do
      template.concat @builder.range_field(attribute_name, @options[:input_html])
    end
  end

end