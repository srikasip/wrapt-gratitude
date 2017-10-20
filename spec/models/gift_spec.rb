require "rails_helper"

describe Gift do
  let(:gift) { FactoryGirl.create(:gift, :multi_product, cost: 100).reload }

  it 'should get cost from products' do
    gift.calculate_cost_from_products = true
    expect(gift.cost).to eq gift.products.sum(&:wrapt_cost)
  end

  it "should get cost from self" do
    gift.calculate_cost_from_products = false
    expect(gift.cost).to eq 100
  end

  it "should get weight from products" do
    gift.calculate_weight_from_products = true
    expect(gift.weight_in_pounds).to eq gift.products.sum(&:weight_in_pounds)
  end

  it "should get weight from self" do
    gift.calculate_weight_from_products = false
    expect(gift.weight_in_pounds).to eq gift.read_attribute(:weight_in_pounds)
  end
end
