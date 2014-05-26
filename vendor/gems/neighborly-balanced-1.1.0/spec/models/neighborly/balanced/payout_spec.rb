require 'spec_helper'

describe Neighborly::Balanced::Payout do
  let(:project) do
    double('Project')
  end
  let(:neighborly_customer) do
    double('Neighborly::Balanced::Customer').as_null_object
  end
  let(:amount)    { BigDecimal.new(100) }
  let(:requestor) { double('User') }
  subject { described_class.new(project, requestor) }
  before do
    subject.stub(:amount).and_return(amount)
    subject.stub(:neighborly_customer).and_return(neighborly_customer)
  end

  describe "completion" do
    before do
      neighborly_customer.stub(:bank_accounts).
                          and_return(bank_accounts)
    end

    context "when customer already has a bank account" do
      let(:bank_accounts) { [double('::Balanced::BankAccount')] }

      it "credits the amount (in cents) to costumer's account" do
        expect(neighborly_customer).to receive(:credit).with(hash_including(amount: 10000))
        subject.complete!
      end

      context 'with successful credit' do
        it 'logs the payout' do
          expect(::Payout).to receive(:create).
            with(hash_including(
              payment_service: 'balanced',
              project_id:      project,
              user_id:         requestor,
              value:           amount))
            subject.complete!
        end
      end

      context 'with unsuccessful credit' do
        before do
          neighborly_customer.
            stub(:credit).
            and_raise(Balanced::Conflict.new({}))
        end

        it 'skips payout logging' do
          expect(::Payout).to_not receive(:create)
          subject.complete! rescue Balanced::Conflict
        end
      end
    end

    context "when customer has no bank accounts" do
      let(:bank_accounts) { [] }

      it "skips credit call" do
        expect(neighborly_customer).to_not receive(:credit)
        subject.complete! rescue Neighborly::Balanced::Error
      end

      it "raises NoBankAccount exception" do
        expect {
          subject.complete!
        }.to raise_error(Neighborly::Balanced::NoBankAccount)
      end
    end
  end

  describe "customer" do
    it "gets the Customer related to User" do
      updated_customer = double('customer')
      neighborly_customer.stub(:fetch).and_return(updated_customer)
      expect(subject.customer).to eql(updated_customer)
    end
  end
end
