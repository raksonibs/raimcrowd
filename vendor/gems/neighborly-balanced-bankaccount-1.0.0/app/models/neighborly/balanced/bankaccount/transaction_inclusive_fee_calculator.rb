require 'float_extensions'

module Neighborly::Balanced::Bankaccount
  class TransactionInclusiveFeeCalculator < TransactionFeeCalculatorBase
    using FloatExtensions

    # Base calculation of fees
    # 1% + 30¢ ($5 cap)
    def net_amount
      [
        ((transaction_value - 0.3) / 1.01).floor_with_two_decimal_places,
        transaction_value - 5
      ].max
    end
  end
end
