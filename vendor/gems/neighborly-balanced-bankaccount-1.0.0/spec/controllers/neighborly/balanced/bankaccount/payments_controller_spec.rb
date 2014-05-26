require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::PaymentsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  let(:current_user) { double('User').as_null_object }
  let(:customer) do
    double('::Balanced::Customer',
           bank_accounts: [double('::Balanced::BankAccount', uri: '/ABANK')],
           uri:           '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    ::Configuration.stub(:fetch).and_return('SOME_KEY')
    Neighborly::Balanced::Bankaccount::PaymentGenerator.any_instance.stub(:complete)
    controller.stub(:authenticate_user!)
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'get new' do
    it 'should use accounts controller new action' do
      expect_any_instance_of(
        Neighborly::Balanced::Bankaccount::AccountsController
      ).to receive(:new)
      get :new, contribution_id: 42
    end
  end

  describe 'POST create' do
    let(:payment) do
      double('Payment', status: :succeeded).as_null_object
    end
    let(:params) do
      {
        'payment' => {
          'contribution_id' => '42',
          'use_bank'        => '/ABANK',
          'user'            => {}
        },
      }
    end

    it 'should receive authenticate_user!' do
      expect(controller).to receive(:authenticate_user!)
      post :create, params
    end

    before do
      Neighborly::Balanced::Bankaccount::PaymentGenerator.
        any_instance.
        stub(:status).
        and_return(:succeeded)
    end

    it 'generates new payment with given params' do
      Neighborly::Balanced::Bankaccount::PaymentGenerator.should_receive(:new).
        with(customer, an_instance_of(Contribution), params['payment']).
        and_return(payment)
      post :create, params
    end

    it 'completes a payment of the contribution' do
      Neighborly::Balanced::Bankaccount::PaymentGenerator.any_instance.should_receive(:complete)
      post :create, params
    end

    context 'with successul checkout' do
      it 'redirects to contribute page' do
        post :create, params
        expect(response).to redirect_to('/projects/forty-two/contributions/42')
      end
    end

    context 'with unsuccessul checkout' do
      before do
        Neighborly::Balanced::Bankaccount::PaymentGenerator.
          any_instance.
          stub(:status).
          and_return(:failed)
      end

      it 'redirects to contribution edit page' do
        post :create, params
        expect(response).to redirect_to('/projects/forty-two/contributions/42/edit')
      end
    end

    describe 'insertion of bank account to a customer' do
      it 'should use accounts controller attach_bank_to_customer method' do
        expect_any_instance_of(
          Neighborly::Balanced::Bankaccount::AccountsController
        ).to receive(:attach_bank_to_customer)
        post :create, params
      end
    end

    describe 'update customer' do
      it 'update user attributes and balanced customer' do
        expect_any_instance_of(
          Neighborly::Balanced::Customer
        ).to receive(:update!)
        post :create, params
      end
    end
  end
end
