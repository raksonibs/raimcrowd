module FloatExtensions
  refine Float do
    def floor_with_two_decimal_places
      (self * 100).floor / 100.0
    end

    def ceil_with_two_decimal_places
      BigDecimal(to_s).ceil(2).to_f
    end
  end
end
