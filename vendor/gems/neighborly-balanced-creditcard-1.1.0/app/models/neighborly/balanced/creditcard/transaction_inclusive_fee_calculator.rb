require 'float_extensions'

module Neighborly::Balanced::Creditcard
  class TransactionInclusiveFeeCalculator < TransactionFeeCalculatorBase
    using FloatExtensions

    # Base calculation of fees
    # 2.9% + 30¢
    def net_amount
      ((transaction_value - 0.3) / 1.029).floor_with_two_decimal_places
    end
  end
end
