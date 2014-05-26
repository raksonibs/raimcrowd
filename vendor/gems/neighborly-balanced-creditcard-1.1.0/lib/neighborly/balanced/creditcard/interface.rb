module Neighborly::Balanced::Creditcard
  class Interface

    def name
      'balanced-creditcard'
    end

    def payment_path(contribution)
      Neighborly::Balanced::Creditcard::Engine.
        routes.url_helpers.new_payment_path(contribution_id: contribution)
    end

    def account_path
      false
    end

    def fee_calculator(value)
      TransactionAdditionalFeeCalculator.new(value)
    end

    def payout_class
      Neighborly::Balanced::Payout
    end

  end
end
