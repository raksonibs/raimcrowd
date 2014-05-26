require 'draper'

module Neighborly::Balanced
  class CustomerDecorator < Draper::Decorator
    delegate_all

    delegate :bank_accounts, to: :fetch

    def bank_account_name
      @bank_account ||= bank_accounts.first
      "#{@bank_account.bank_name} #{@bank_account.account_number}"
    end
  end
end
