require 'spec_helper'

describe Neighborly::Balanced::Payment do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:debit)        { double('::Balanced::Debit').as_null_object }
  let(:attributes)   { { use_card: 'my-new-card' } }
  let(:project_owner_customer) do
    double('::Balanced::Customer', uri: 'project-owner-uri')
  end

  subject do
    described_class.new('balanced-creditcard',
                        customer,
                        contribution,
                        attributes)
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(project_owner_customer)
    contribution.stub_chain(:project, :user, :balanced_contributor).and_return(
      double('BalancedContributor', uri: 'project-owner-uri'))

    described_class.any_instance.stub(:meta).and_return({})
  end

  describe "contribution amount in cents" do
    context "when customer is paying fees" do
      let(:attributes) { { pay_fee: '1', use_card: 'my-new-card' } }

      it "returns gross amount from TransactionAdditionalFeeCalculator" do
        Neighborly::Balanced::Creditcard::TransactionAdditionalFeeCalculator.
          any_instance.stub(:gross_amount).and_return(15)
        expect(subject.contribution_amount_in_cents).to eql(1500)
      end
    end

    context "when customer is not paying fees" do
      let(:attributes) { { pay_fee: '0', use_card: 'my-new-card' } }

      it "returns gross amount from TransactionInclusiveFeeCalculator" do
        Neighborly::Balanced::Creditcard::TransactionInclusiveFeeCalculator.
          any_instance.stub(:gross_amount).and_return(10)
        expect(subject.contribution_amount_in_cents).to eql(1000)
      end
    end
  end

  describe "checkout" do
    shared_examples "updates contribution object" do
      let(:attributes) { { pay_fee: '1', use_card: 'my-new-card' } }

      it "debits customer on selected funding instrument" do
        customer.should_receive(:debit).
                 with(hash_including(source_uri: 'my-new-card')).
                 and_return(debit)
        subject.checkout!
      end

      it "defines given engine's name as payment method of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_method: 'balanced-creditcard'))
        subject.checkout!
      end

      it "saves paid fees on contribution object" do
        calculator = double('FeeCalculator', fees: 0.42).as_null_object
        subject.stub(:fee_calculator).and_return(calculator)
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_service_fee: 0.42))
        subject.checkout!
      end

      it "saves who paid the fees" do
        calculator = double('FeeCalculator', fees: 0.42).as_null_object
        subject.stub(:fee_calculator).and_return(calculator)
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_service_fee_paid_by_user: '1'))
        subject.checkout!
      end
    end

    context "when customer is paying fees" do
      let(:attributes) { { pay_fee: '1', use_card: 'my-new-card' } }

      it "debits customer with contribution amount in cents" do
        subject.stub(:contribution_amount_in_cents).and_return(1000)
        customer.should_receive(:debit).
                 with(hash_including(amount: 1000)).
                 and_return(debit)
        subject.checkout!
      end
    end

    context "with successful debit" do
      before { customer.stub(:debit).and_return(debit) }

      include_examples "updates contribution object"

      it "confirms the contribution" do
        expect(contribution).to receive(:confirm!)
        subject.checkout!
      end

      it 'defines id as payment id of the contribution' do
        debit.stub(:id).and_return('i-am-an-id!')
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_id: 'i-am-an-id!'))
        subject.checkout!
      end

      it 'defines appears_on_statement_as on debit' do
        ::Configuration.stub(:[]).with(:balanced_appears_on_statement_as).
          and_return('Neighbor.ly')

        customer.should_receive(:debit).
                 with(hash_including(appears_on_statement_as: 'Neighbor.ly')).
                 and_return(debit)
        subject.checkout!
      end

      it 'defines description on debit' do
        contribution.stub_chain(:project, :name).and_return('Awesome Project')
        customer.should_receive(:debit).
                 with(hash_including(description: 'Contribution to Awesome Project')).
                 and_return(debit)
        subject.checkout!
      end

      it 'defines on_behalf_of_uri on debit' do
        customer.should_receive(:debit).
                 with(hash_including(on_behalf_of_uri: 'project-owner-uri')).
                 and_return(debit)
        subject.checkout!
      end

      it 'defines meta on debit' do
        described_class.any_instance.stub(:meta).and_return({ payment_service_fee: 5.0 })
        customer.should_receive(:debit).
                 with(hash_including(meta: { payment_service_fee: 5.0 })).
                 and_return(debit)
        subject.checkout!
      end
    end

    context "when raising Balanced::PaymentRequired exception" do
      before do
        customer.stub(:debit).and_raise(Balanced::PaymentRequired.new({}))
      end

      include_examples "updates contribution object"

      it "cancels the contribution" do
        expect(contribution).to receive(:cancel!)
        subject.checkout!
      end
    end
  end

  describe "successful state" do
    before do
      customer.stub(:debit).and_return(debit)
    end

    context "after checkout" do
      before { subject.checkout! }

      it "is successfull when the debit has 'succeeded' status" do
        debit.stub(:status).and_return('succeeded')
        expect(subject).to be_successful
      end

      it "is successfull when the debit has 'pending' status" do
        debit.stub(:status).and_return('pending')
        expect(subject).to be_successful
      end

      it "is not successfull when the debit has others statuses" do
        debit.stub(:status).and_return('failed')
        expect(subject).to_not be_successful
      end
    end

    context "before checkout" do
      it "is not successfull" do
        expect(subject).to_not be_successful
      end
    end
  end
end
