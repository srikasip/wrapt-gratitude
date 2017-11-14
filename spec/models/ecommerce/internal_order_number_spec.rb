require "rails_helper"

describe InternalOrderNumber do
  it "should work" do
    expect(InternalOrderNumber.humanize(0)).to eq '000-000-000'
    expect(InternalOrderNumber.humanize(1)).to eq '000-000-001'
    expect(InternalOrderNumber.humanize(14_000)).to eq '000-014-000'
  end
end
