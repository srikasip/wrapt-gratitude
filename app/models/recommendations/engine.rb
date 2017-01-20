module Recommendations
  class Engine

    # TODO as of 8/31/16
    # accomodate the front end survey responses
    # accomodate multiple multiple choice questions
    # exclude text questions
    # tests

    attr_reader :training_set, :response, :recommendations

    NEGATIVE_RANK_PENALTY = 2
    QUESTION_WEIGHT_BASE = 10
    MIN_NUMBER_OF_RECOMMENDATIONS = 10

    def initialize(training_set, response = nil)
      @training_set = training_set
      self.response = response
    end
    
    def response=(new_response)
      @response = new_response
      if @response.present? && (training_set.survey_id != @response.survey_id)
        raise SurveyMismatchError
      end
      clear_recommendations
      @response
    end
    
    def destroy_recommendations!
      EvaluationRecommendation.where(
        survey_response: response,
        training_set_evaluation:
        training_set.evaluation).delete_all
    end

    def generate_recommendations
      @recommendations = []
      
      generate_candidate_recommendations
      remove_similar_recommendations
      
      # take 80% of the recommended ones and leave 20% for random
      @recommendations = @recommendations.take((0.8 * MIN_NUMBER_OF_RECOMMENDATIONS).round)
      
      # are we short?
      if @recommendations.length < MIN_NUMBER_OF_RECOMMENDATIONS
        generate_random_recommendations(2 * (MIN_NUMBER_OF_RECOMMENDATIONS - @recommendations.length))
        remove_similar_recommendations
        
        # are we still short?
        if @recommendations.length < MIN_NUMBER_OF_RECOMMENDATIONS
          generate_random_recommendations(MIN_NUMBER_OF_RECOMMENDATIONS - @recommendations.length)
        elsif @recommendations.length > MIN_NUMBER_OF_RECOMMENDATIONS
          @recommendations = @recommendations.take(MIN_NUMBER_OF_RECOMMENDATIONS)
        end
      end
      
      @recommendations
    end

    def clear_recommendations
      @recommendations = []
      @_question_responses_by_question = nil
      true
    end
    
    def create_recommendations!
      @recommendations.map(&:save)
    end

    # TODO this is used by EvaluationRecommendations#show and could be moved closer to there
    def calculate_question_rank_intermediate_products gift, question
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]
      result = {}
      result[:initial_question_rank] = initial_question_rank(gift, question)
      result[:negative_rank_penalty_applied] = Recommendations::NegativeRankPenaltyApplicator.new(result[:initial_question_rank]).modified_rank
      result[:question_weight_applied] = Recommendations::ProductQuestionWeightApplicator.new(result[:negative_rank_penalty_applied], gift_question&.question_impact).modified_rank
      result[:final_question_rank] = result[:question_weight_applied]
      result
    end
    
    protected
    
    def generate_random_recommendations(count)
      gift_pool = random_gifts - @recommendations.map(&:gift)
      added = []
      gift_pool.sample(count).each do |gift|
        added << add_recommendation(gift, 0.0)
      end
      added
    end
      
    def add_recommendation(gift, score = 0.0)
      recommendation = EvaluationRecommendation.new(
        survey_response: response,
        gift: gift,
        training_set_evaluation: training_set.evaluation,
        score: score)
      
      @recommendations << recommendation
      
      recommendation
    end
    
    def generate_candidate_recommendations
      max_rank = 0.0
      training_set_gifts.each do |gift|
        gift_rank = 0
        questions_by_gift[gift].each do |question|
          gift_rank += calculate_question_rank(gift, question)
        end
        if gift_rank > 0.0
          add_recommendation(gift, gift_rank)
          max_rank = gift_rank if gift_rank > max_rank
        end
      end
      # reject the bottom quartile
      @recommendations.reject!{|r| r.score < 0.25 * max_rank}
      @recommendations.sort!{|a, b| b.score <=> a.score}
      
      @recommendations
    end
    
    def remove_similar_recommendations
      used_categories = []
      @recommendations.reject! do |recommendation|
        categories = categories_by_gifts[recommendation.gift]
        if (used_categories & categories).any?
          true # don't use it
        else
          used_categories += categories
          false
        end
      end
    end

    def calculate_question_rank gift, question
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]

      result = initial_question_rank(gift, question)
      result = Recommendations::NegativeRankPenaltyApplicator.new(result).modified_rank
      result = Recommendations::ProductQuestionWeightApplicator.new(result, gift_question&.question_impact).modified_rank
    end

    def initial_question_rank gift, question
      result = 0
      question_response = question_responses_by_question[question]
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]
      if question_response && gift_question
        calculator_class = case question
        when ::SurveyQuestions::MultipleChoice then Recommendations::QuestionRankCalculators::MultipleChoice
        when ::SurveyQuestions::Range then Recommendations::QuestionRankCalculators::Range
        end
        result = calculator_class.new(gift_question, question_response).question_rank
      end
      result
    end
    
    def gifts
      training_set_gifts + random_gifts
    end

    def training_set_gifts
      @_training_set_gifts ||= Gift.preload(:product_subcategory, products: [:product_subcategory]).where(id: training_set.gift_question_impacts.select(:gift_id)).to_a
    end

    def random_gifts
      @_random_gifts ||= Gift.preload(:product_subcategory, products: [:product_subcategory]).order('RANDOM()').limit(50).to_a
    end

    def categories_by_gifts
      @_categories_by_gift ||= {}.tap do |result|
        gifts.each do |gift|
          result[gift] = gift.products.map(&:product_subcategory)
        end
      end
    end

    def questions_by_gift
      @_questions_by_gift ||= {}.tap do |result|
        training_set.gift_question_impacts.preload(:gift, :survey_question).each do |gift_question|
          result[gift_question.gift] ||= []
          result[gift_question.gift] << gift_question.survey_question
        end
      end
    end
    
    def gift_question_impacts_by_gift_and_question
      @_gift_question_impacts_by_gift_and_question ||= {}.tap do |result|
        training_set.gift_question_impacts.preload(:gift, :survey_question, :response_impacts).each do |gift_question|
          gift = gift_question.gift
          question = gift_question.survey_question
          result[gift] ||= {}
          result[gift][question] = gift_question
        end
      end
    end

    def question_responses_by_question
      @_question_responses_by_question ||= {}.tap do |result|
        response.question_responses.preload(:survey_question).each do |question_response|
          result[question_response.survey_question] = question_response
        end
      end  
    end
    
    class SurveyMismatchError; end

  end
end