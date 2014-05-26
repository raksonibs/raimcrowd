require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::Interface do
  let(:contribution) { double('Contribution', id: 42) }

  it 'should return the engine name' do
    expect(subject.name).to eq 'balanced-bankaccount'
  end

  it 'should return payment path' do
    expect(subject.payment_path(contribution)).to eq Neighborly::Balanced::Bankaccount::Engine.
        routes.url_helpers.new_payment_path(contribution_id: contribution)
  end

  it 'should return account path' do
    expect(subject.account_path).to eq Neighborly::Balanced::Bankaccount::Engine.
        routes.url_helpers.new_account_path
  end

  it 'should return an instance of TransactionAdditionalFeeCalculator' do
    expect(subject.fee_calculator(10)).to be_an_instance_of(Neighborly::Balanced::Bankaccount::TransactionAdditionalFeeCalculator)
  end
end
