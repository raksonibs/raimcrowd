require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::TransactionAdditionalFeeCalculator do
  subject { described_class.new(transaction_value) }

  context "when gross amount doesn't need more then 2 decimal places of precision" do
    let(:transaction_value) { 100.0 }

    it "has net amount equal to transaction value" do
      expect(subject.net_amount).to eql(transaction_value)
    end

    context "when base calculation of fees gets lesser than $5" do
      it "has gross amount equal following Balanced's formula" do
        expect(subject.gross_amount).to eql(101.3)
      end

      it "has fees matching the difference between gross and net amounts" do
        expect(subject.fees).to eql(1.3)
      end
    end

    context "when base calculation of fees gets greater than $5" do
      # Using just percentage calculation the gross amount would be 1010.3
      let(:transaction_value) { 1000.0 }

      it "has gross amount equal to net amount plus 5" do
        expect(subject.gross_amount).to eql(1005.0)
      end

      it "has fees equal to 5" do
        expect(subject.fees).to eql(5.0)
      end
    end
  end

  context "when gross amount does need more then 2 decimal places of precision" do
    # Float gross amount is 101.401
    let(:transaction_value) { 100.1 }

    it "has net amount equal to transaction value" do
      expect(subject.net_amount).to eql(transaction_value)
    end

    it "rounds gross amount up by two decimal places" do
      expect(subject.gross_amount).to eql(101.41)
    end

    it "has fees matching with the rounding" do
      expect(subject.fees).to eql(1.31)
    end
  end
end
