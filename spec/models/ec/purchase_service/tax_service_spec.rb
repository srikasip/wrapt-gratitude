require 'rails_helper'

RSpec.describe Ec::PurchaseService::TaxService do
  let(:profile)     { FactoryGirl.create(:profile, :with_gift_selections) }
  let(:tax_service) { Ec::PurchaseService::TaxService.new(customer_order: @customer_order) }

  before :each do
    service = Ec::PurchaseService.find_existing_cart_or_initialize(profile: profile, user: profile.owner)
    service.generate_order!
    @customer_order = service.customer_order
    @customer_order.ship_street1 = '10109 Floyd'
    @customer_order.ship_city = 'Overland Park'
    @customer_order.ship_state = 'KS'
    @customer_order.ship_zip = '66212'
    @customer_order.ship_country = 'US'
    @customer_order.save!
  end

  it "should default to an estimate" do
    expect(tax_service).to be_estimate
  end

  it "should estimate taxes without crashing" do
    VCR.use_cassette('estimate taxes') do
      tax_service.estimate!
    end
  end

  it "should estimate and reconcile taxes without crashing" do
    VCR.use_cassette('estimate and reconcile') do
      tax_service.estimate!
      expect(tax_service.success?).to be_truthy
      tax_service.reconcile!
    end
  end
end
