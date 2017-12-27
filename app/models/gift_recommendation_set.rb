class GiftRecommendationSet < ApplicationRecord
  belongs_to :profile
  has_many :recommendations,
    -> {order(expert_score: :desc, position: :asc, score: :desc, id: :asc)},
    dependent: :destroy, class_name: 'GiftRecommendationSet'
  
  belongs_to :expert, class_name: 'User'

  serialize :engine_params
  
  ENGINE_TYPES = %w{survey_response_engine}
  
  validates :engine_type, inclusion: {in: ENGINE_TYPES}
  
  def engine
    @_engine || create_engine
  end
  
  def create_engine
    type_to_class = {'survey_response_engine' => Recommender::SurveyResponseEngine}
    engine_class = type_to_class[engine_type]
    @_engine = engine_class.new(self)
  end
  
  def generate_recommendations!
    engine.destroy_recommendations!
    engine.run
    engine.save_recommendations!
    gift_recommendations
  end
end