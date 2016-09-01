require "test_helper"

module Recommendations

  class ProductQuestionWeightApplicatorTest < ActiveSupport::TestCase

    attr_reader :subject

    def test_modified_rank
      rank = 3
      question_impact = 0.5

      @subject = Recommendations::ProductQuestionWeightApplicator.new(rank, question_impact)
      assert_equal 6, subject.modified_rank
    end

  end
end
