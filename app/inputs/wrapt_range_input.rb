class WraptRangeInput < SimpleForm::Inputs::Base

  def input(wrapper_options)
    input_options = @options[:input_html]
    label_options = @options[:labels] || {}
    template.content_tag :div, class: 'wrapt-range__container' do
      template.concat @builder.range_field(attribute_name, input_options)
      if label_options.present?
        template.concat labels(template, label_options)
      end
    end
  end

  def labels(template, label_options)
    template.content_tag :div, class: 'wrapt-range__labels text-center' do
      label_options.keys.each do |key|
        template.concat content_tag :div, label_options[key], class: "small wrapt-range__label wrapt-range__#{key.to_s.gsub('_', '-')}"
      end
    end
  end

end