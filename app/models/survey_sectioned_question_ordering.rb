class SurveySectionedQuestionOrdering
  # Takes a survey (to enforce scope)
  # and an array of section data of the format
  # [{id: "8", question_ordering: ["6", "3", "5"]}]

  # calling save will assign the given questions to the given section in the
  # given order
  
  attr_reader :survey, :sections_attributes, :sort_order_attribute

  def initialize attrs
    @survey = attrs.fetch :survey
    @sections_attributes = attrs.fetch :sections_attributes
    @sort_order_attribute = attrs[:sort_order_attribute] || :sort_order
  end

  def save
    sections_attributes.each do |section_attrs|
      section = @survey.sections_with_uncategorized.detect{|section| section.id == section_attrs[:id].presence&.to_i}
      section_attrs[:question_ordering].each_with_index do |question_id, i|
        @survey
          .questions
          .detect{|question| question.id == question_id.to_i}
          .update survey_section_id: section.id, sort_order: i+1
      end

    end
  end


end