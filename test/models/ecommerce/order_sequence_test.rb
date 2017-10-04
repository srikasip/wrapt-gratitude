require "test_helper"

class OrderSequenceTest < ActiveSupport::TestCase
  def test_basic_behavior
    assert_equal('000-000-000', InternalOrderNumber.humanize(0))
    assert_equal('000-000-001', InternalOrderNumber.humanize(1))
    assert_equal('000-002-89H', InternalOrderNumber.humanize(14_435))
    assert_equal('008-E0E-4H6', InternalOrderNumber.humanize(298_635_000))
    assert_equal('AAF-FAF-A4G', InternalOrderNumber.humanize(910_298_635_000))
  end
end
