begin
  PaymentEngine.new(Neighborly::Balanced::Bankaccount::Interface.new).save
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
