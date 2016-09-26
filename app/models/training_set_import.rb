class TrainingSetImport < ExcelImport

  importable_name :training_set

  def required_headers
    TrainingSets::Imports::Row::ATTRIBUTE_HEADERS + %w{response_impact_1}
  end
end
