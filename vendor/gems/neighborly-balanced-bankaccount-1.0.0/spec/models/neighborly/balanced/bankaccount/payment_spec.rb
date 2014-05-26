require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::Payment do
  let(:customer)     { double('::Balanced::Customer', uri: '/CUSTOMER-ID') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:debit)        { double('::Balanced::Debit').as_null_object }
  let(:bank_account) { double('::Balanced::BankAccount', uri: '/ABANK') }
  let(:attributes)   { { use_bank: bank_account.uri } }
  let(:project_owner_customer) do
    double('::Balanced::Customer', uri: 'project-owner-uri')
  end
  subject do
    described_class.new('balanced-bankaccount',
                        customer,
                        contribution,
                        attributes)
  end
  before do
    subject.stub(:debit_resource).and_return(bank_account)
    customer.stub(:debit).and_return(debit)

    ::Balanced::Customer.stub(:find).and_return(project_owner_customer)
    contribution.stub_chain(:project, :user, :balanced_contributor).and_return(
      double('BalancedContributor', uri: 'project-owner-uri'))

    described_class.any_instance.stub(:meta).and_return({})
  end

  describe 'contribution amount in cents' do
    context 'when customer is paying fees' do
      let(:attributes) { { pay_fee: '1', use_bank: bank_account.uri } }

      it 'returns gross amount from TransactionAdditionalFeeCalculator' do
        Neighborly::Balanced::Bankaccount::TransactionAdditionalFeeCalculator.
          any_instance.stub(:gross_amount).and_return(15)
        expect(subject.contribution_amount_in_cents).to eql(1500)
      end
    end

    context 'when customer is not paying fees' do
      let(:attributes) { { pay_fee: '0', use_bank: bank_account.uri } }

      it 'returns gross amount from TransactionInclusiveFeeCalculator' do
        Neighborly::Balanced::Bankaccount::TransactionInclusiveFeeCalculator.
          any_instance.stub(:gross_amount).and_return(10)
        expect(subject.contribution_amount_in_cents).to eql(1000)
      end
    end
  end

  describe 'checkout' do
    shared_examples 'updates contribution object' do
      let(:attributes)  { { pay_fee: '1', use_bank: bank_account.uri } }

      context 'when a source_uri is provided' do
        it 'debits customer on selected funding instrument' do
          customer.should_receive(:debit).
                   with(hash_including(source_uri: bank_account.uri)).
                   and_return(debit)
          subject.checkout!
        end
      end

      context 'when no source_uri is provided' do
        let(:contributor) do
          double('Neighborly::Balanced::Contributor', bank_account_uri: '/MY-DEFAULT-BANK')
        end
        let(:attributes) { { pay_fee: '1' } }
        before { subject.stub(:contributor).and_return(contributor) }

        it 'debits customer on default funding instrument' do
          customer.should_receive(:debit).
                   with(hash_including(source_uri: contributor.bank_account_uri)).
                   and_return(debit)
          subject.checkout!
        end
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

    context 'with successful debit' do
      before { customer.stub(:debit).and_return(debit) }

      include_examples 'updates contribution object'

      it 'confirms the contribution' do
        expect(contribution).to receive(:confirm!)
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

      it 'defines id as payment id of the contribution' do
        debit.stub(:id).and_return('i-am-an-id!')
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_id: 'i-am-an-id!'))
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

    context 'when raising Balanced::BadRequest exception' do
      before do
        customer.stub(:debit).and_raise(Balanced::BadRequest.new({}))
      end

      include_examples 'updates contribution object'

      it 'cancels the contribution' do
        expect(contribution).to receive(:cancel!)
        subject.checkout!
      end
    end

    context 'when a description is provided to debit' do
      it 'defines description on debit' do
        contribution.stub_chain(:project, :name).and_return('Awesome Project')
        customer.should_receive(:debit).
                 with(hash_including(description: 'Contribution to Awesome Project')).
                 and_return(debit)
        subject.checkout!
      end
    end
  end

  describe 'status' do
    context 'after checkout' do
      before do
        subject.checkout!
      end

      it 'returns the debit status symbolized' do
        debit.stub(:status).and_return('my_status')
        expect(subject.status).to eql(:my_status)
      end
    end

    context 'before checkout' do
      it 'is nil' do
        expect(subject.status).to be_nil
      end
    end
  end

  describe 'successful state' do
    before do
      customer.stub(:debit).and_return(debit)
    end

    context 'after checkout' do
      before { subject.checkout! }

      it 'is successfull when the debit has \'succeeded\' status' do
        debit.stub(:status).and_return('succeeded')
        expect(subject).to be_successful
      end

      it 'is successfull when the debit has \'pending\' status' do
        debit.stub(:status).and_return('pending')
        expect(subject).to be_successful
      end

      it 'is not successfull when the debit has others statuses' do
        debit.stub(:status).and_return('failed')
        expect(subject).to_not be_successful
      end
    end

    context 'before checkout' do
      it 'is not successfull' do
        expect(subject).to_not be_successful
      end
    end
  end
end
