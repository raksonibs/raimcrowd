require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::ConfirmationsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  let(:current_user) { double('User').as_null_object }
  let(:verification) { double('::Balanced::Verification',
                                state: 'unverified',
                                remaining_attempts: 2) }
  let(:customer) do
    double('::Balanced::Customer',
           bank_accounts: [double('::Balanced::BankAccount', uri: '/ABANK',
                                  verifications: [verification]
                                 )],
           uri:           '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    ::Configuration.stub(:fetch).and_return('SOME_KEY')
    Notification.stub(:notify)
    controller.stub(:authenticate_user!)
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'GET new' do
    let(:i18n_scope) { 'neighborly.balanced.bankaccount.confirmations.new' }

    it 'should receive authenticate_user!' do
      expect(controller).to receive(:authenticate_user!)
      get :new
    end

    context 'when user has a bank account' do
      it 'should fetch balanced customer' do
        expect_any_instance_of(
          Neighborly::Balanced::Customer
        ).to receive(:fetch).and_return(customer)
        get :new
      end

      it 'should render application layout' do
        get :new
        expect(response).to render_template(layout: 'application')
      end

      it 'should complete the request successfully' do
        get :new
        expect(response.status).to eq 200
      end

      it 'should assign bank_account to view' do
        get :new
        expect(assigns(:bank_account)).to_not be_nil
      end

      it 'should assign contributions to view' do
        contributions = [double('Contribution')]
        current_user.contributions.stub(:with_state).and_return(contributions)
        get :new
        expect(assigns(:contributions)).to eq(contributions)
      end

      it 'should assign customer to view' do
        get :new
        expect(assigns(:customer)).to eq customer
      end
    end

    context 'when user do not have a bank account' do
      before { customer.stub(:bank_accounts).and_return([]) }

      it 'should redirect to user payments page' do
        get :new
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'should set a flash message' do
        get :new
        expect(flash.alert).to eq I18n.t('errors.bank_account_not_found', scope: i18n_scope)
      end
    end

    context 'when user has a bank account already confirmed' do
      let(:verification) { double('::Balanced::Verification', state: 'verified') }

      it 'should redirect to user payments page' do
        get :new
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'should set a flash message' do
        get :new
        expect(flash.alert).to eq I18n.t('errors.already_confirmed', scope: i18n_scope)
      end
    end
  end

  describe 'POST create' do
    let(:i18n_scope) { 'neighborly.balanced.bankaccount.confirmations.create' }
    let(:params) do
      {
        'confirmation' => {
          'amount_1' => '1',
          'amount_2' => '2'
        },
      }
    end

    it 'should receive authenticate_user!' do
      verification.stub(:confirm)
      expect(controller).to receive(:authenticate_user!)
      post :create, params
    end

    context 'when confirmation succeed' do
      it 'confirm bank account' do
        expect(verification).to receive(:confirm).with('1', '2')
        post :create, params
      end

      it 'should redirect to user payments page' do
        verification.stub(:confirm)
        post :create, params
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'should set a flash message' do
        verification.stub(:confirm)
        post :create, params
        expect(flash.notice).to eq I18n.t('messages.success', scope: i18n_scope)
      end
    end

    context 'when confirmation failed' do
      before do
        verification.stub(:confirm).
          and_raise(Balanced::BankAccountVerificationFailure.new({}))
      end

      context 'with remaining attempts' do
        it 'should redirect to new confirmation page' do
          post :create, params
          expect(response).to redirect_to(new_confirmation_path)
        end

        it 'should alert the user about the error' do
          post :create, params
          expect(flash.alert).to eq I18n.t('messages.unable_to_verify', scope: i18n_scope)
        end
      end

      context 'with do no remaining attempts' do
        before do
          # Balanced does not decrease Verification#remaining_attempts
          # after a fail attempt
          verification.stub(:remaining_attempts).and_return(1)
        end

        it 'should start a new verification' do
          expect(customer.bank_accounts.first).to receive(:verify)
          post :create, params
        end

        it 'notify user about new verification process started' do
          customer.bank_accounts.first.stub(:verify)
          expect(Notification).to receive(:notify).
            with('balanced/bankaccount/new_verification_started', anything)
          post :create, params
        end

        it 'should redirect to new confirmation page' do
          customer.bank_accounts.first.stub(:verify)
          post :create, params
          expect(response).to redirect_to(new_confirmation_path)
        end

        it 'should alert the user about the error' do
          customer.bank_accounts.first.stub(:verify)
          post :create, params
          expect(flash.alert).to eq I18n.t('messages.not_remaining_attempts', scope: i18n_scope)
        end
      end
    end
  end
end
