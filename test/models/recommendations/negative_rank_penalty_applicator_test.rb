require "test_helper"

module Recommendations
  class NegativeRankPenaltyApplicatorTest < ActiveSupport::TestCase

    attr_reader :subject

    def test_modified_rank_when_positive
      @subject = Recommendations::NegativeRankPenaltyApplicator.new(5)
      assert_equal 5, subject.modified_rank
    end

    def test_modified_rank_when_negative
      @subject = Recommendations::NegativeRankPenaltyApplicator.new(-5)
      assert_equal -10, subject.modified_rank
    end

  end
end
