require 'spec_helper'

describe Neighborly::Balanced::Creditcard::TransactionInclusiveFeeCalculator do
  # Float net amount is 971.5257531584064
  let(:transaction_value) { 1000.0 }
  subject { described_class.new(transaction_value) }

  it "has gross amount equal to transaction value" do
    expect(subject.gross_amount).to eql(transaction_value)
  end

  it "rounds net amount down by two decimal places" do
    expect(subject.net_amount).to eql(971.52)
  end

  it "has fees matching with the rounding" do
    expect(subject.fees).to eql(28.48)
  end
end
