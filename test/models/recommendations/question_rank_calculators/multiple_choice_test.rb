require "test_helper"

module Recommendations
  module QuestionRankCalculators
    class MultipleChoiceTest < ActiveSupport::TestCase

      attr_reader :subject, :product_question, :question_response

      def setup
        @product_question = object_double(TrainingSetProductQuestion.new)
        @question_response = object_double(SurveyQuestionResponse.new)
        @subject = Recommendations::QuestionRankCalculators::MultipleChoice.new(product_question, question_response)
      end

      def test_question_rank
        allow(question_response).to receive(:survey_question_option_id) { 78 }

        selected_response_impact = object_double(TrainingSetResponseImpact.new, survey_question_option_id: 78, impact: 0.75)
        other_response_impact = object_double(TrainingSetResponseImpact.new, survey_question_option_id: 84, impact: -0.33)
        allow(product_question).to receive(:response_impacts) { [selected_response_impact, other_response_impact] }

        assert_equal(0.75, subject.question_rank)
      end

      def test_question_rank_when_impact_not_found
        allow(question_response).to receive(:survey_question_option_id) { 78 }

        other_response_impact = object_double(TrainingSetResponseImpact.new, survey_question_option_id: 84, impact: -0.33)
        allow(product_question).to receive(:response_impacts) { [other_response_impact] }

        assert_equal(0, subject.question_rank)
      end

    end
  end
end

