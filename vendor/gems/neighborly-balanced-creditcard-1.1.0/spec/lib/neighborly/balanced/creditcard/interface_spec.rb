require 'spec_helper'

describe Neighborly::Balanced::Creditcard::Interface do
  let(:contribution) { double('Contribution', id: 42) }

  it 'should return the engine name' do
    expect(subject.name).to eq 'balanced-creditcard'
  end

  it 'should return payment path' do
    expect(subject.payment_path(contribution)).to eq Neighborly::Balanced::Creditcard::Engine.
        routes.url_helpers.new_payment_path(contribution_id: contribution)
  end

  it 'should return account path' do
    expect(subject.account_path).to be_false
  end

  it 'should return an instance of TransactionAdditionalFeeCalculator' do
    expect(subject.fee_calculator(10)).to be_an_instance_of(Neighborly::Balanced::Creditcard::TransactionAdditionalFeeCalculator)
  end
end

