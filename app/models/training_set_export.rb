require 'write_xlsx'

class TrainingSetExport
  include ActiveModel::Model

  attr_accessor :training_set
  
  def generate_file!
    FileUtils.mkdir_p Rails.root.join("tmp", "training_set_exports")
    export_file_path = Rails.root.join("tmp", "training_set_exports", export_file_name).to_s

    @workbook = WriteXLSX.new export_file_path
    @worksheet = @workbook.add_worksheet

    write_headers!
    write_impact_rows!
    set_column_widths!

    @workbook.close

    return export_file_path
  end

  private def export_file_name
    "wrapt_gift_training_set_#{training_set.name.underscore}_#{Time.now.strftime('%Y-%m-%d-%H%M%S%L')}.xlsx"
  end

  private def headers
    %w{
      gift_sku
      question_code
      question_impact
      slider_impact_direction
      choice_1_impact
      choice_2_impact
      choice_3_impact
      choice_4_impact
      choice_5_impact
      choice_6_impact
      choice_7_impact
      choice_8_impact
      choice_9_impact
      choice_10_impact
    }
  end

  private def write_headers!
    headers.each_with_index do |header, i|
      @worksheet.write 0, i, header
    end  
  end

  private def write_impact_rows!
    row = 1
    training_set.gift_question_impacts.preload(survey_question: :options).preload(:response_impacts, :gift).each do |impact|
      @worksheet.write row, 0, impact.gift.wrapt_sku
      @worksheet.write row, 1, impact.survey_question.code
      @worksheet.write row, 2, impact.question_impact
      @worksheet.write row, 3, slider_impact_direction_value(impact)
      write_choice_impacts row, impact
      row += 1
    end    
  end

  private def set_column_widths!
    @worksheet.set_column 0, 0, 20
    @worksheet.set_column 1, 1, 15
    @worksheet.set_column 2, 2, 15
    @worksheet.set_column 3, 3, 20
    @worksheet.set_column 4, 4, 15
    @worksheet.set_column 5, 5, 15
    @worksheet.set_column 6, 6, 15
    @worksheet.set_column 7, 7, 15
    @worksheet.set_column 8, 8, 15
    @worksheet.set_column 9, 9, 15
    @worksheet.set_column 10, 10, 15
    @worksheet.set_column 11, 11, 15
    @worksheet.set_column 12, 12, 15
    @worksheet.set_column 13, 13, 15
  end

  private def slider_impact_direction_value impact
    if impact.survey_question.is_a? ::SurveyQuestions::Range
      if impact.range_impact_direct_correlation?
        1
      else
        -1
      end
    end
  end

  private def write_choice_impacts row, impact
    impact.survey_question.options.each_with_index do |option, i|
      col = 4 + i

      option_impact = impact.response_impacts.detect{|response_impact| response_impact.survey_question_option_id == option.id}
      if option_impact
        @worksheet.write row, col, option_impact.impact
      end
    end
  end
  
  


end