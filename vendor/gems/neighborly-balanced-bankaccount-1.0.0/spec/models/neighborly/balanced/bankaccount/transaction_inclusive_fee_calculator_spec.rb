require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::TransactionInclusiveFeeCalculator do
  # Float net amount is 98.712871287
  let(:transaction_value) { 100.0 }
  subject { described_class.new(transaction_value) }

  it 'has gross amount equal to transaction value' do
    expect(subject.gross_amount).to eql(transaction_value)
  end

  context 'when base calculation of fees gets lesser than $5' do
    it 'has net amount equal following Balanced\'s formula, rouding down by two decimal places' do
      expect(subject.net_amount).to eql(98.71)
    end

    it 'has fees matching with the rounding' do
      expect(subject.fees).to eql(1.29)
    end
  end

  context 'when base calculation of fees gets greater than $5' do
    # Using just percentage calculation the net amount would be 989.801980198
    let(:transaction_value) { 1000.0 }

    it 'has net amount equal to transaction value minus 5' do
      expect(subject.net_amount).to eql(995.0)
    end

    it 'has fees equal to 5' do
      expect(subject.fees).to eql(5.0)
    end
  end
end
