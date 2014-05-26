module Neighborly::Balanced::Bankaccount
  class Interface

    def name
      'balanced-bankaccount'
    end

    def payment_path(contribution)
      Neighborly::Balanced::Bankaccount::Engine.
        routes.url_helpers.new_payment_path(contribution_id: contribution)
    end

    def account_path
      Neighborly::Balanced::Bankaccount::Engine.
        routes.url_helpers.new_account_path
    end

    def fee_calculator(value)
      TransactionAdditionalFeeCalculator.new(value)
    end

    def payout_class
      Neighborly::Balanced::Payout
    end

  end
end
