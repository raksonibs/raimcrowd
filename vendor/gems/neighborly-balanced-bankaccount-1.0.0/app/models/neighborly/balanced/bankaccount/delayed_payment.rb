module Neighborly::Balanced::Bankaccount
  class DelayedPayment < PaymentBase
    def checkout!
      @contribution.wait_confirmation!

      @status = :succeeded
      @contribution.update_attributes(
        payment_method:                   @engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: @attrs[:pay_fee]
      )
    end

    def successful?
      @status.eql? :succeeded
    end
  end
end
