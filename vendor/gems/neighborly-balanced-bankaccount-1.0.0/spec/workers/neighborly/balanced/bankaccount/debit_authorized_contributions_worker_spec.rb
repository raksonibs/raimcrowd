require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::DebitAuthorizedContributionsWorker do
  let(:contributor) { double('Contributor', id: 45, user_id: user.id) }
  let(:user)        { double('User', id: 42) }
  before do
    Neighborly::Balanced::Contributor.stub(:find).and_return(contributor)
  end

  describe 'performation' do
    let(:contributions) do
      [double('Contribution', state: :confirmed, user_id: user.id)]
    end
    let(:payment_processing) do
      double('DelayedPaymentProcessing')
    end
    before do
      subject.stub(:waiting_confirmation_contributions).
              and_return(contributions)
    end

    it 'completes payments of all contributions waiting confirmation' do
      Neighborly::Balanced::Bankaccount::DelayedPaymentProcessing.
        stub(:new).
        with(contributor, contributions).
        and_return(payment_processing)
      expect(payment_processing).to receive(:complete)
      subject.perform(contributor.id)
    end
  end
end
