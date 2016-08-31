require "test_helper"

module Recommendations

  class ProductQuestionWeightApplicatorTest < ActiveSupport::TestCase

    attr_reader :subject, :engine, :product, :question

    def test_modified_rank
      rank = 3
      product_question = object_double(TrainingSetProductQuestion.new, question_impact: 0.5)
      @product = object_double Product.new
      @question = object_double SurveyQuestion.new
      product_questions_by_product_and_question = {product => {question => product_question}}
      @engine = instance_double Recommendations::Engine, product_questions_by_product_and_question: product_questions_by_product_and_question

      @subject = Recommendations::ProductQuestionWeightApplicator.new(rank, engine: engine, product: product, question: question)
      assert_equal 6, subject.modified_rank
    end

  end
end
