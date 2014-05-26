require 'spec_helper'

describe Neighborly::Balanced::EventRegistered do
  let(:user) { double('User') }
  let(:event) do
    double('Neighborly::Balanced::Event',
           entity_uri: '/verifications/MYEVENT',
           user:       user)
  end

  describe 'confirmation' do
    context 'with \'bank_account_verification.deposited\' event' do
      before do
        event.stub(:type).and_return('bank_account_verification.deposited')
      end

      it 'generates \'confirm_bank_account\' notification' do
        expect(Notification).to receive(:notify).
          with('balanced/bankaccount/confirm_bank_account', anything)
        subject.confirm(event)
      end
    end

    context 'with \'bank_account_verification.verified\' event' do
      let(:verification) { double('Neighborly::Balanced::Bankaccount::Verification') }
      before do
        event.stub(:type).and_return('bank_account_verification.verified')
      end

      it 'confirms the bank account verification' do
        Neighborly::Balanced::Bankaccount::Verification.stub(:find).
          with('/verifications/MYEVENT').
          and_return(verification)
        expect(verification).to receive(:confirm)
        subject.confirm(event)
      end
    end

    context 'with other types of events' do
      before do
        event.stub(:type).and_return('bank_account_verification.created')
      end

      it 'skips generation of notifications' do
        expect(Notification).to_not receive(:notify)
        subject.confirm(event)
      end
    end
  end
end
