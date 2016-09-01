require "test_helper"

module Recommendations
  module QuestionRankCalculators
    class RangeTest < ActiveSupport::TestCase

      attr_reader :subject, :product_question, :question_response

      def setup
        @product_question = object_double(TrainingSetProductQuestion.new)
        @question_response = object_double(SurveyQuestionResponse.new)
        @subject = Recommendations::QuestionRankCalculators::Range.new(product_question, question_response)
      end

      def test_question_rank_when_direct_correlation
        allow(product_question).to receive(:range_impact_direct_correlation?) { true }
        allow(question_response).to receive(:range_response) { 0.75 }
        assert_equal(0.75, subject.question_rank)
      end

      def test_question_rank_when_indirect_correlation
        allow(product_question).to receive(:range_impact_direct_correlation?) { false }
        allow(question_response).to receive(:range_response) { 0.75 }
        assert_equal(-0.75, subject.question_rank)
      end

    end
  end
end

