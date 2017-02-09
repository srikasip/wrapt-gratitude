class TrainingSetImport < Import

  importable_name :training_set, ExcelImportRecordsFileUploader

  def initialize attrs = {}
    super
    @question_scope = training_set.survey.questions
  end

  def preload!
    sheet.cache_columns_scan!(:gift_sku, :question_code)
    preload_one!(Gift, :gift_sku, :wrapt_sku)
    preload_one!(@question_scope, :question_code, :code)
    preload_question_impacts!
  end

  def record_association_name
    :gift_question_impacts
  end

  def required_headers
    TrainingSets::Imports::Row::ATTRIBUTE_HEADERS + TrainingSets::Imports::Row::MANY_TO_ONE_HEADERS
  end

  def row_record(row)
    question = @preloads[@question_scope][row.question_code]
    gift = @preloads[Gift][row.gift_sku]

    question_impact =
      @preloads[GiftQuestionImpact][[question.id, gift.id]] ||
      question.gift_question_impacts.new(gift: gift)

    conversion = TrainingSets::Imports::Conversion.new(row)

    question_impact.question_impact = conversion.question_impact

    question_impact.range_impact_direct_correlation = conversion.range_impact_direct_correlation(question)

    question_impact.response_impacts.destroy_all
    question_impact.response_impacts = conversion.response_impacts(question)

    question_impact
  end

  #

  def preload_question_impacts!
    @preloads ||= {}

    @preloads[GiftQuestionImpact] ||=
      GiftQuestionImpact.
        where(
          training_set: training_set,
          survey_question: @preloads[@question_scope].values,
          gift: @preloads[Gift].values
        ).
        index_by do |record|
          [record.survey_question_id, record.gift_id]
        end
  end
end
