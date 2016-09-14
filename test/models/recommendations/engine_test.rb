require "test_helper"

module Recommendations
  class EngineTest < ActiveSupport::TestCase
  
    attr_reader :subject
  
    def setup
      @test_data = TestData.new
      @test_data.load_data!
    end

    def teardown
      @test_data.cleanup!
    end

    def test_recommends_tipi_to_rafe
      @subject = Recommendations::Engine.new @test_data.training_set, @test_data.rafe_response
      subject.generate_recommendations!
      top_recommendation = @test_data.training_set.evaluation.recommendations.where(survey_response: @test_data.rafe_response).order('score DESC').first
      assert_equal @test_data.tipi_gift, top_recommendation.gift
    end

    def test_recommends_incense_to_ely
      @subject = Recommendations::Engine.new @test_data.training_set, @test_data.ely_response
      subject.generate_recommendations!
      top_recommendation = @test_data.training_set.evaluation.recommendations.where(survey_response: @test_data.ely_response).order('score DESC').first
      assert_equal @test_data.incense_gift, top_recommendation.gift
    end


  
  end
end
