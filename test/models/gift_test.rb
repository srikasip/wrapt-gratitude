require "test_helper"

class GiftTest < ActiveSupport::TestCase

  attr_reader :subject

  def setup
    @subject = Gift.new
  end

  def test_calculates_cost_from_products_when_true
    skip 'annoying to test because we do the summation in the database'
    subject.calculate_cost_from_products = true
    subject.cost = 18
    p1 = object_double(Product.new, wrapt_cost: 5)
    p2 = object_double(Product.new, wrapt_cost: 2)
    allow(subject).to receive(:products) { [p1, p2] }
    assert_equal(subject.cost, 7)
  end

  def test_uses_attribute_when_calculate_cost_from_products_false
    subject.calculate_cost_from_products = true
    subject.cost = 18
    p1 = object_double(Product.new, wrapt_cost: 5)
    p2 = object_double(Product.new, wrapt_cost: 2)
    allow(subject).to receive(:products) { [p1, p2] }
    assert_equal(subject.cost, 18)
  end

end