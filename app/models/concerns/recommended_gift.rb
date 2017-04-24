# abstractions used by the recommendation engine.

module RecommendedGift
  extend ActiveSupport::Concern
  
  included do
    belongs_to :gift
    
    delegate :featured?, :experience?, to: :gift
  end
  
  def random?
    score < Recommendations::Engine::RECOMMENDATION_SCORE_THRESHOLD
  end
end