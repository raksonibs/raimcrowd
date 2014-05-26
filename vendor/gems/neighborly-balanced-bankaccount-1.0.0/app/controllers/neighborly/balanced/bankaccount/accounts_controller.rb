module Neighborly::Balanced::Bankaccount
  class AccountsController < ActionController::Base
    before_filter :authenticate_user!

    def new
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      # @bank_account            = customer.bank_accounts.try(:last)
      render layout: false
    end

    def create
      attach_bank_to_customer

      flash[:success] = t('neighborly.balanced.bankaccount.accounts.create.success')
      redirect_to main_app.payments_user_path(current_user)
    end

    private

    def attach_bank_to_customer
      new_bank_account_uri = resource_params.fetch(:use_bank)
      unless customer_bank_accounts.any? { |c| c.uri.eql? new_bank_account_uri }
        Neighborly::Balanced::Contributor.
          find_or_create_by(user_id: current_user.id).
          update_attributes(bank_account_uri: new_bank_account_uri)
        notify_user_about_replacement
        unstore_all_bank_accounts
        # Not calling #reload raises Balanced::ConflictError when attaching a
        # new card after unstoring others.
        customer.reload.add_bank_account(new_bank_account_uri)
        verify_bank_account(new_bank_account_uri)
      end
    end

    def notify_user_about_replacement
      Notification.notify('balanced/bankaccount/bank_account_replaced',
                          current_user) if customer_bank_accounts.any?
    end

    def verify_bank_account(bank_account)
      Balanced::BankAccount.find(bank_account).verify
    end

    def unstore_all_bank_accounts
      customer_bank_accounts.each do |bank|
        bank.unstore
      end
    end

    def customer_bank_accounts
      @bank_accounts ||= customer.bank_accounts
    end

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_bank,
                    :pay_fee,
                    user: {})
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end

