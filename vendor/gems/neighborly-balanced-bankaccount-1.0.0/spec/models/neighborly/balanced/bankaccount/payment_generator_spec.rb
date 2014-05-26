require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::PaymentGenerator do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:attrs)        { { use_bank: '/ABANK' } }
  let(:bank_account) { double('::Balanced::BankAccount', verifications: []) }
  subject { described_class.new(customer, contribution, attrs) }

  before do
    ::Balanced::BankAccount.stub(:find).and_return(bank_account)
  end

  describe 'ability to debit resource' do
    before do
      bank_account.stub(:verifications).and_return(verifications)
    end

    context 'with confirmed verification' do
      let(:verifications) do
        [double('::Balanced::Verification', state: 'verified')]
      end

      it 'is able to debit resource' do
        expect(subject.can_debit_resource?).to be_true
      end
    end

    context 'with verification started' do
      let(:verifications) do
        [double('::Balanced::Verification', state: 'deposit_succeeded')]
      end

      it 'isn\'t able to debit resource' do
        expect(subject.can_debit_resource?).to be_false
      end
    end

    context 'without verifications' do
      let(:verifications) { [] }

      it 'isn\'t able to debit resource' do
        expect(subject.can_debit_resource?).to be_false
      end
    end
  end

  describe 'completion' do
    it 'checkouts using Payment class when is able to debit resource' do
      subject.stub(:can_debit_resource?).and_return(true)
      expect_any_instance_of(
        Neighborly::Balanced::Bankaccount::Payment
      ).to receive(:checkout!)
      subject.complete
    end

    it 'checkouts using DelayedPayment when is not able to debit resource' do
      subject.stub(:can_debit_resource?).and_return(false)
      expect_any_instance_of(
        Neighborly::Balanced::Bankaccount::DelayedPayment
      ).to receive(:checkout!)
      subject.complete
    end
  end
end
