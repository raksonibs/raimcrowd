begin
  # Uncomment the following line to enable Balanced Bank Account engine again.
  # PaymentEngine.new(Neighborly::Balanced::Bankaccount::Interface.new).save
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
