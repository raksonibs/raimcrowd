module Neighborly::Balanced::Bankaccount
  describe RoutingNumber do
    it { should validate_presence_of :number }
    it { should validate_presence_of :bank_name }
  end
end
