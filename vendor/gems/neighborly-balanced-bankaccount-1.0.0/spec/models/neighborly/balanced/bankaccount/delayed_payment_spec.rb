require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::DelayedPayment do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:bank_account) { double('::Balanced::BankAccount', uri: '/ABANK') }
  let(:attributes)   { { pay_fee: '1', use_bank: bank_account.uri } }
  subject do
    described_class.new('balanced-bankaccount',
                        customer,
                        contribution,
                        attributes)
  end

  describe 'checkout' do
    it 'authorizes payment of contribution' do
      expect(contribution).to receive(:wait_confirmation!)
      subject.checkout!
    end

    it 'defines given engine\'s name as payment method of the contribution' do
      contribution.should_receive(:update_attributes).
                   with(hash_including(payment_method: 'balanced-bankaccount'))
      subject.checkout!
    end

    it 'saves paid fees on contribution object' do
      calculator = double('FeeCalculator', fees: 0.42).as_null_object
      subject.stub(:fee_calculator).and_return(calculator)
      contribution.should_receive(:update_attributes).
                   with(hash_including(payment_service_fee: 0.42))
      subject.checkout!
    end

    it 'saves who paid the fees' do
      calculator = double('FeeCalculator', fees: 0.42).as_null_object
      subject.stub(:fee_calculator).and_return(calculator)
      contribution.should_receive(:update_attributes).
                   with(hash_including(payment_service_fee_paid_by_user: '1'))
      subject.checkout!
    end
  end

  describe 'status' do
    context 'after checkout' do
      before do
        subject.checkout!
      end

      it 'is succeeded' do
        expect(subject.status).to eql(:succeeded)
        expect(subject).to        be_successful
      end
    end

    context 'before checkout' do
      it 'is nil' do
        expect(subject.status).to be_nil
      end

      it 'is not succeeded' do
        expect(subject).to_not be_successful
      end
    end
  end
end
