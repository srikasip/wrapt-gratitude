class SurveyResponseTraitEvaluation < ApplicationRecord
  belongs_to :response, class_name: 'ProfileSetSurveyResponse'
  belongs_to :trait_training_set
  store_accessor :matched_tag_id_counts

  def stale?
    updated_at < trait_training_set.updated_at ||
    updated_at < response.updated_at
  end

  def matched_tags
    ProfileTraits::Tag.where(id: matched_tag_id_counts.keys)
  end


end
