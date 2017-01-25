module Recommendations
  class QuestionRank
    attr_reader :response, :impact, :score
    
    delegate :gift, :survey_question, to: :impact
    alias :question :survey_question
    
    def initialize(response, impact, score)
      @score = score
      @response = response
      @impact = impact
    end
  end
end