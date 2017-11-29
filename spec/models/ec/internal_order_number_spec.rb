require "rails_helper"

describe Ec::InternalOrderNumber do
  it "should work" do
    expect(Ec::InternalOrderNumber.humanize(0)).to eq '000-000-000'
    expect(Ec::InternalOrderNumber.humanize(1)).to eq '000-000-001'
    expect(Ec::InternalOrderNumber.humanize(14_000)).to eq '000-014-000'
  end
end
