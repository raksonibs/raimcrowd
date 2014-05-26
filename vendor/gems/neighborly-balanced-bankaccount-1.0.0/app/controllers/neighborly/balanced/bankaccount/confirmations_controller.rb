module Neighborly::Balanced::Bankaccount
  class ConfirmationsController < ApplicationController
    before_filter :authenticate_user!
    before_action :check_bank_account_availability, only: :new

    def new
      @verification  = verification
      @contributions = current_user.contributions.with_state(:waiting_confirmation)
      render layout: 'application'
    end

    def create
      verification.confirm(params[:confirmation][:amount_1],
                           params[:confirmation][:amount_2])

      flash.notice = t('.messages.success')
      redirect_to main_app.payments_user_path(current_user)
    rescue Balanced::BankAccountVerificationFailure
      # Balanced does not decrease Verification#remaining_attempts
      # after a failure
      @remaining_attempts = verification.remaining_attempts - 1
      flash.alert = t('.messages.unable_to_verify')
      check_for_remaining_attempts
      redirect_to new_confirmation_path
    end

    private
    def check_for_remaining_attempts
      if @remaining_attempts.zero?
        flash.alert = t('.messages.not_remaining_attempts')
        create_new_verification
      end
    end

    def create_new_verification
      bank_account.verify
      Notification.notify('balanced/bankaccount/new_verification_started',
                          current_user)
    end

    def check_bank_account_availability
      if bank_account
        if verification.try(:state) == 'verified'
          flash.alert = t('.errors.already_confirmed')
          has_errors = true
        end
      else
        flash.alert = t('.errors.bank_account_not_found')
        has_errors = true
      end
      redirect_to main_app.payments_user_path(current_user) if has_errors
    end

    def verification
      @verification ||= bank_account.verifications.try(:first)
    end

    def bank_account
      @bank_account ||= customer.bank_accounts.try(:last)
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end
