module Recommendations
  class Engine

    # TODO as of 8/31/16
    # accomodate the front end survey responses
    # accomodate multiple multiple choice questions
    # exclude text questions
    # tests

    attr_reader :training_set, :response, :recommendations, :response_adapter, :question_ranks,
      :filters

    delegate :add_recommendation,
      :destroy_recommendations!,
      to: :response_adapter
      
    delegate :survey, to: :training_set

    NEGATIVE_RANK_PENALTY = 5.0
    QUESTION_WEIGHT_BASE = 100.0
    MIN_NUMBER_OF_RECOMMENDATIONS = 12
    RECOMMENDATION_SCORE_THRESHOLD = 5.0
    CATEGORY_LIMIT = 2
    MIN_RANDOM = 2
    RANDOM_SCORE = 0.0
    FEATURED_SCORE = 0.1

    def initialize(training_set, response = nil)
      @training_set = training_set
      self.response = response
    end
    
    def response=(new_response)
      @response = new_response
      set_response_adapter
      if @response.present? && (training_set.survey_id != @response.survey_id)
        raise SurveyMismatchError
      end

      clear_recommendations
      
      @filters = []
      
      create_filters if response.present?
      
      @response
    end

    private def set_response_adapter
      if @response.present?
        case @response
        when ProfileSetSurveyResponse then @response_adapter = Recommendations::ProfileSetSurveyResponseAdapter.new(self)
        when SurveyResponse then @response_adapter = Recommendations::SurveyResponseAdapter.new(self)
        else raise UnsupportedSurveyResponseError
        end
      end      
    end
    
    def generate_recommendations
      clear_recommendations
      
      generate_candidate_recommendations
      apply_filters
      remove_similar_recommendations
      
      @recommendations = @recommendations.take(MIN_NUMBER_OF_RECOMMENDATIONS - MIN_RANDOM)
      
      # are we short?
      if @recommendations.length < MIN_NUMBER_OF_RECOMMENDATIONS
        generate_random_recommendations(10 * (MIN_NUMBER_OF_RECOMMENDATIONS - @recommendations.length))
        apply_filters
        remove_similar_recommendations
        
        # are we still short?
        if @recommendations.length < MIN_NUMBER_OF_RECOMMENDATIONS
          generate_random_recommendations(MIN_NUMBER_OF_RECOMMENDATIONS - @recommendations.length)
        elsif @recommendations.length > MIN_NUMBER_OF_RECOMMENDATIONS
          @recommendations = @recommendations.take(MIN_NUMBER_OF_RECOMMENDATIONS)
        end
      end
      
      @recommendations.sort!{|a, b| b.score <=> a.score}
      
      @recommendations
    end

    def clear_recommendations
      @recommendations = []
      @question_ranks = []
      @_question_responses_by_question = nil
      true
    end
    
    def create_recommendations!
      @recommendations.map(&:save)
    end
    
    def recommendation_question_ranks(recommendation)
      results = question_ranks.select{|qr| qr.gift == recommendation.gift}
      results.sort!{|a, b| b.score <=> a.score}
      results
    end

    def question_responses_by_question
      @_question_responses_by_question ||= {}.tap do |result|
        response.question_responses.preload(:survey_question, :survey_question_options).each do |question_response|
          result[question_response.survey_question] = question_response
        end
      end  
    end
    
    def applied_filters
      filters.select(&:applied?)
    end
    
    protected
    
    def create_filters
      @filters = Recommendations::Filters::Base.create_filters(self)
    end
    
    def apply_filters
      filters.each do |filter|
        @recommendations = filter.apply(@recommendations)
      end
      @recommendations
    end
    
    def generate_random_recommendations(count)
      added = []

      if added.length < count
        gift_pool = experience_gifts - @recommendations.map(&:gift)
        # force one experience gift into the random set
        gift_pool.sample(1).each do |gift|
          added << add_recommendation(gift, FEATURED_SCORE)
        end
      end
      
      if added.length < count
        gift_pool = featured_random_gifts - @recommendations.map(&:gift)
        gift_pool.sample(count - added.length).each do |gift|
          added << add_recommendation(gift, FEATURED_SCORE)
        end
      end
      
      if added.length < count
        gift_pool = non_featured_random_gifts - @recommendations.map(&:gift)
        gift_pool.sample(count - added.length).each do |gift|
          added << add_recommendation(gift, RANDOM_SCORE)
        end
      end
      
      added
    end
    
    def generate_candidate_recommendations
      max_rank = 0.0
      training_set_gifts.each do |gift|
        gift_rank = 0
        questions_by_gift[gift].each do |question|
          gift_rank += calculate_question_rank(gift, question)
        end
        if gift_rank >= RECOMMENDATION_SCORE_THRESHOLD
          add_recommendation(gift, gift_rank)
          max_rank = gift_rank if gift_rank > max_rank
        end
      end

      @recommendations.sort!{|a, b| b.score <=> a.score}
      
      @recommendations
    end
    
    def remove_similar_recommendations
      used_category_counts = {}
      @recommendations.reject! do |recommendation|
        max_category_count = 0
        categories_by_gifts[recommendation.gift].each do |category|
          category_count = used_category_counts.fetch(category, 0.0) + 1
          max_category_count = category_count if category_count > max_category_count
          used_category_counts[category] = category_count
        end
        max_category_count > CATEGORY_LIMIT
      end
    end

    def calculate_question_rank gift, question
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]

      result = initial_question_rank(gift, question)
      result = Recommendations::NegativeRankPenaltyApplicator.new(result).modified_rank
      result = Recommendations::ProductQuestionWeightApplicator.new(result, gift_question&.question_impact).modified_rank
      
      add_question_rank(gift, question, result)
      
      result
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
    
    def add_question_rank(gift, question, score)
      response = question_responses_by_question[question]
      impact = gift_question_impacts_by_gift_and_question[gift][question]
      if response.present? && impact.present? && score != 0.0
        question_rank = Recommendations::QuestionRank.new(response, impact, score)
        question_ranks << question_rank
        question_rank
      else
        nil
      end
    end
    
    def gifts
      training_set_gifts + featured_random_gifts + non_featured_random_gifts + experience_gifts
    end

    def training_set_gifts
      @_training_set_gifts ||= Gift.preload(:product_subcategory, products: [:product_subcategory]).where(id: training_set.gift_question_impacts.select(:gift_id)).to_a
    end

    def featured_random_gifts
      @_featured_random_gifts ||= Gift.preload(:product_subcategory, products: [:product_subcategory]).where(featured: true).order('RANDOM()').limit(50).to_a
    end
    
    def non_featured_random_gifts
      @_non_featured_random_gifts ||= Gift.preload(:product_subcategory, products: [:product_subcategory]).where(featured: false).order('RANDOM()').limit(50).to_a
    end
    
    def experience_gifts
      @_experience_gifts ||=
        Gift.preload(:product_subcategory, products: [:product_subcategory]).
        where(featured: true).
        where(product_subcategory: ProductCategory.where(wrapt_sku_code: ProductCategory::EXPERIENCE_GIFT_CODE)).
        order('RANDOM()').limit(50).to_a
    end

    def categories_by_gifts
      @_categories_by_gift ||= Hash.new([]).tap do |result|
        gifts.each do |gift|
          categories = gift.products.map(&:product_subcategory)
          categories << gift.product_subcategory if gift.product_subcategory.wrapt_sku_code == ProductCategory::EXPERIENCE_GIFT_CODE
          result[gift] = categories
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
    
    class SurveyMismatchError; end
    class UnsupportedSurveyResponseError < StandardError; end

  end
end