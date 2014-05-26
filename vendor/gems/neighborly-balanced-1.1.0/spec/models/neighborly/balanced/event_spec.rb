require 'spec_helper'

describe Neighborly::Balanced::Event do
  let(:contribution)      { double('Contribution', id: 49) }
  let(:user)              { double('User') }
  let(:contributor)       { double('Neighborly::Balanced::Contributor', user: user) }
  let(:notification_type) { 'debit.created' }
  let(:params)            { attributes_for_notification(notification_type) }
  subject { described_class.new(params) }

  it 'gets the type from request params' do
    expect(subject.type).to eql('debit.created')
  end

  it 'gets the entity uri from request params' do
    expect(subject.entity_uri).to eql('/v1/marketplaces/TEST-MP24PC81sknFKEuhffrbAixq/debits/WD3q99CpFnVTDWMgfXpiC2Mo')
  end

  describe "validability" do
    before { subject.stub(:contribution).and_return(contribution) }

    context "when contribution exists" do
      context "when its value and payment matches" do
        before do
          contribution.stub(:price_in_cents).and_return(params[:entity][:amount].to_i)
        end

        it { should be_valid }
      end

      context "when value does not match with payment" do
        before do
          contribution.stub(:price_in_cents).and_return((params[:entity][:amount]+1).to_i)
        end

        it { should_not be_valid }
      end
    end

    context "when no contribution does not exist" do
      let(:contribution) { nil }

      it { should_not be_valid }
    end

    context 'with \'bank_account_verification.deposited\'' do
      let(:notification_type) do
        'bank_account_verification.deposited'
      end

      it { should be_valid }
    end

    context 'with \'bank_account_verification.verified\'' do
      let(:notification_type) do
        'bank_account_verification.verified'
      end

      it { should be_valid }
    end
  end

  shared_examples 'storing payment notification' do
    it 'creates a new payment notification' do
      subject.stub(:contribution).and_return(contribution)
      expect(PaymentEngine).to receive(:create_payment_notification).
        with(hash_including(contribution_id: contribution.id))
      subject.save
    end

    it 'stores metadata of event' do
      expect(PaymentEngine).to receive(:create_payment_notification).
        with(hash_including(:extra_data))
      subject.save
    end

    it 'sets as changed for observers' do
      expect(described_class).to receive(:changed)
      subject.save
    end

    it 'notifies observers' do
      expect(described_class).to receive(:notify_observers).with(subject)
      subject.save
    end
  end

  context 'with debit.created params' do
    let(:notification_type) { 'debit.created' }

    it_behaves_like 'storing payment notification'
  end

  context 'with debit.succeeded params' do
    let(:notification_type) { 'debit.succeeded' }

    it_behaves_like 'storing payment notification'
  end

  context 'with bank_account_verification.deposited params' do
    let(:notification_type) { 'bank_account_verification.deposited' }

    it_behaves_like 'storing payment notification'

    it 'gets its contributor from request params' do
      Configuration.stub(:[]).with(:balanced_marketplace_id).and_return('QWERTY')
      Neighborly::Balanced::Contributor.stub(:find_by).
        with(bank_account_uri: '/v1/marketplaces/QWERTY/bank_accounts/BAPGUSU1HHB5kWPcBmnxEq6').
        and_return(contributor)
      expect(subject.contributor).to eql(contributor)
    end

    it 'gets its user from request params' do
      subject.stub(:contributor).and_return(contributor)
      expect(subject.user).to eql(user)
    end
  end

  context 'with debit.canceled params' do
    let(:notification_type) { 'debit.canceled' }

    it_behaves_like 'storing payment notification'
  end

  context 'with bank_account_verification.verified params' do
    let(:notification_type) { 'bank_account_verification.verified' }

    it_behaves_like 'storing payment notification'

    it 'gets its contributor from request params' do
      Configuration.stub(:[]).with(:balanced_marketplace_id).and_return('QWERTY')
      Neighborly::Balanced::Contributor.stub(:find_by).
        with(bank_account_uri: '/v1/marketplaces/QWERTY/bank_accounts/BA4xYXDZ7vv62KvVAlgtRIXd').
        and_return(contributor)
      expect(subject.contributor).to eql(contributor)
    end

    it 'gets its user from request params' do
      subject.stub(:contributor).and_return(contributor)
      expect(subject.user).to eql(user)
    end
  end
end
