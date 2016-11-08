require 'write_xlsx'

class ProfileSetFileExportJob < ApplicationJob
  queue_as :default

  attr_reader :profile_set, :target_file_path, :workbook, :worksheet

  def perform(profile_set, target_file_path)
    @profile_set = profile_set
    @target_file_path = target_file_path
    @workbook = WriteXLSX.new target_file_path
    @worksheet = workbook.add_worksheet

    write_headers!
    write_response_rows!

    workbook.close
  end

  private def headers
    %w(
      survey_response_name
      question_code
      text_response
      slider_response
      choice_1
      choice_3
      choice_4
      choice_5
      choice_6
      choice_7
      choice_8
      choice_9
      choice_10
    )
  end

  private def write_headers!
    headers.each_with_index do |header, i|
      worksheet.write 0, i, header
    end    
  end

  private def write_response_rows!
    row = 1
    profile_set.survey_responses.preload(question_responses: [{survey_question: :options}, :survey_question_response_options]).each do |survey_response|
      survey_response.question_responses.each do |question_response|
        worksheet.write row, 0, survey_response.name
        worksheet.write row, 1, question_response.survey_question.code
        worksheet.write row, 2, question_response.text_response
        worksheet.write row, 3, question_response.range_response

        question_response.survey_question.options.each_with_index do |option, i|
          col = 4 + i
          if question_response.survey_question_response_options.any? {|response_option| response_option.survey_question_option_id == option.id}
            worksheet.write row, col, "1"
          else
            worksheet.write row, col, "0"
          end
        end

        row +=1
      end
    end
  end
  
  
  
end
