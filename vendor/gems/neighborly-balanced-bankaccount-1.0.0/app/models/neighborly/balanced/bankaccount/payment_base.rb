module Neighborly::Balanced::Bankaccount
  class PaymentBase
    def initialize(engine_name, customer, contribution, attrs = {})
      @engine_name  = engine_name
      @customer     = customer
      @contribution = contribution
      @attrs        = attrs
    end

    def contribution_amount_in_cents
      (fee_calculator.gross_amount * 100).round
    end

    def fee_calculator
      @fee_calculator and return @fee_calculator

      calculator_class = if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? @attrs[:pay_fee]
                           TransactionAdditionalFeeCalculator
                         else
                           TransactionInclusiveFeeCalculator
                         end

      @fee_calculator = calculator_class.new(@contribution.value)
    end

    def debit
      @debit.try(:sanitize)
    end

    def status
      @debit.try(:status).try(:to_sym) || @status
    end

    def checkout!
      raise NotImplementedError
    end

    def successful?
      raise NotImplementedError
    end
  end
end
