require 'spec_helper'

describe Neighborly::Balanced::Creditcard::TransactionAdditionalFeeCalculator do
  subject { described_class.new(transaction_value) }

  context "when gross amount doesn't need more then 2 decimal places of precision" do
    let(:transaction_value) { 1000.0 }

    it "has net amount equal to transaction value" do
      expect(subject.net_amount).to eql(transaction_value)
    end

    it "has gross amount equal following Balanced's formula" do
      expect(subject.gross_amount).to eql(1029.3)
    end

    it "has fees matching the difference between gross and net amounts" do
      expect(subject.fees).to eql(29.3)
    end
  end

  context "when gross amount does need more then 2 decimal places of precision" do
    # Float gross amount is 1029.329
    let(:transaction_value) { 1001.0 }

    it "has net amount equal to transaction value" do
      expect(subject.net_amount).to eql(transaction_value)
    end

    it "rounds gross amount up by two decimal places" do
      expect(subject.gross_amount).to eql(1030.33)
    end

    it "has fees matching with the rounding" do
      expect(subject.fees).to eql(29.33)
    end
  end
end
