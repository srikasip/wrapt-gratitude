require 'write_xlsx'

class TraitTrainingSetMatchExport
  include ActiveModel::Model

  attr_accessor :trait_training_set, :profile_set
  
  def generate_file!
    ensure_all_matches_are_current!

    FileUtils.mkdir_p Rails.root.join("tmp", "trait_training_set_match_exports")
    export_file_path = Rails.root.join("tmp", "trait_training_set_match_exports", export_file_name).to_s

    @workbook = WriteXLSX.new export_file_path
    @worksheet = @workbook.add_worksheet

    write_headers!
    write_tag_match_rows!
    set_column_widths!

    @workbook.close

    return export_file_path
  end

  private def export_file_name
    "wrapt_profile_trait_matches_#{trait_training_set.name.underscore}_#{profile_set.name.underscore}_#{Time.now.strftime('%Y-%m-%d-%H%M%S%L')}.xlsx"
  end

  private def headers
    [
      "Survey Response",
      "Topic",
      "Facet",
      "Tag",
      "Tag Scale",
      "Tag Match Count"
    ]
  end

  private def write_headers!
    headers.each_with_index do |header, i|
      @worksheet.write 0, i, header
    end  
  end
  
  private def write_tag_match_rows!
    row = 1
    profile_set.survey_responses.each do |survey_response|
      evaluation = trait_training_set.evaluations.where(response: survey_response).first
      evaluation.matched_tags.preload(facet: :topic).each do |tag|
        @worksheet.write row, 0, survey_response.name
        @worksheet.write row, 1, tag.facet.topic.name
        @worksheet.write row, 2, tag.facet.name
        @worksheet.write row, 3, tag.name
        @worksheet.write row, 4, tag.position
        @worksheet.write row, 5, evaluation.matched_tag_id_counts[tag.id.to_s]
        row += 1
      end
    end
  end
  

  private def set_column_widths!
    @worksheet.set_column 0, 0, 25
    @worksheet.set_column 1, 1, 15
    @worksheet.set_column 2, 2, 15
    @worksheet.set_column 3, 3, 25
    @worksheet.set_column 4, 4, 10
    @worksheet.set_column 5, 5, 15
  end

  private def ensure_all_matches_are_current!
    profile_set.survey_responses.each do |survey_response|
      evaluation = trait_training_set.evaluations.where(response: survey_response).first_or_initialize
      matches_need_refresh = evaluation.new_record? || evaluation.stale?
      evaluation.save if evaluation.new_record?
      if matches_need_refresh
        evaluation.update_attribute :matching_in_progress, true
        GenerateTraitEvaluationTagMatchesJob.new.perform(evaluation)
      end
    end
  end

end