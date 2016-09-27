class TrainingSetImport < Import

  importable_name :training_set, ExcelImportRecordsFileUploader

  def record_association
    :gift_question_impacts
  end

  def required_headers
    TrainingSets::Imports::Row::ATTRIBUTE_HEADERS + %w{response_impact_1}
  end

  def row_record(row)
    question_impact = @preloads.dig(GiftQuestionImpact, [row.question_code, row.gift_sku])

    if !question_impact
      question = @preloads.dig(SurveyQuestion, row.question_code)
      gift = @preloads.dig(Gift, row.gift_sku)
      question_impact = question.gift_question_impacts.new(gift: gift)
    end

    conversion = TrainingSets::Imports::Conversion.new(row)

    question_impact.question_impact = conversion.question_impact

    question_impact.range_impact_direct_correlation = conversion.range_impact_direct_correlation(question)

    question_impact.response_impacts.destroy_all
    question_impact.response_impacts = conversion.response_impacts(question)

    question_impact
  end

  #

  def preload!
    sheet.cache_columns_scan!(:gift_sku, :question_code)
    preload_one!(Gift, :gift_sku, :wrapt_sku)
    preload_one!(SurveyQuestion, :question_code, :code)
    preload_question_impacts!
  end

  ##

  def preload_question_impacts!
    @preloads ||= {}

    @preloads[GiftQuestionImpact] ||=
      GiftQuestionImpact.
        where(
          survey_question: @preloads[SurveyQuestion].values,
          gift: @preloads[Gift].values
        ).index_by do |record|
          [record.survey_question_id, record.gift_id]
        end
  end
end
