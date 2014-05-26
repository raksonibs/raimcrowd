require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::DelayedPaymentProcessing do
  let(:contributor) { double('Contributor', uri: '/MYID') }
  let(:customer)    { double('Customer') }
  subject { described_class.new(contributor, contributions) }
  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
  end

  describe 'completion' do
    let(:contribution_1) { double('Contribution') }
    let(:contribution_2) { contribution_1.dup }
    let(:contributions)  { [contribution_1, contribution_2] }

    it 'generates a Payment for each contribution' do
      expect(
        Neighborly::Balanced::Bankaccount::Payment
      ).to receive(:new).with(anything, anything, contribution_1, anything).
                         and_return(double.as_null_object)
      expect(
        Neighborly::Balanced::Bankaccount::Payment
      ).to receive(:new).with(anything, anything, contribution_2, anything).
                         and_return(double.as_null_object)
      subject.complete
    end

    it 'checkouts a Payment for each contribution' do
      payment = double('Neighborly::Balanced::Bankaccount::Payment').as_null_object
      Neighborly::Balanced::Bankaccount::Payment.
        stub(:new).
        and_return(payment)

      expect(payment).to receive(:checkout!).twice
      subject.complete
    end
  end
end
