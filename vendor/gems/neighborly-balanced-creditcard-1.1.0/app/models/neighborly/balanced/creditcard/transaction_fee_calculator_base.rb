require 'float_extensions'

module Neighborly::Balanced::Creditcard
  class TransactionFeeCalculatorBase
    using FloatExtensions

    attr_writer :transaction_value

    def initialize(transaction_value)
      @transaction_value = transaction_value
    end

    def transaction_value
      @transaction_value.to_f.floor_with_two_decimal_places
    end

    def gross_amount
      net_amount + fees
    end

    def net_amount
      raise NotImplementedError
    end

    # Base calculation of fees
    # 2.9% + 30¢
    def fees
      (net_amount * 0.029 + 0.3).ceil_with_two_decimal_places
    end
  end
end
