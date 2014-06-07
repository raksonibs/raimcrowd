begin
  PaymentEngine.new(Neighborly::Balanced::Creditcard::Interface.new).save
rescue Exception => e
  raise "Error while registering payment engine: #{e}"
end
