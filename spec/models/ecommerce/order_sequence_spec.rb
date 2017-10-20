require "rails_helper"

describe InternalOrderNumber do
  it "should work" do
    expect(InternalOrderNumber.humanize(0)).to eq '000-000-000'
    expect(InternalOrderNumber.humanize(1)).to eq '000-000-001'
    expect(InternalOrderNumber.humanize(14_435)).to eq '000-002-89H'
    expect(InternalOrderNumber.humanize(298_635_000)).to eq '008-E0E-4H6'
    expect(InternalOrderNumber.humanize(910_298_635_000)).to eq 'AAF-FAF-A4G'
  end
end
