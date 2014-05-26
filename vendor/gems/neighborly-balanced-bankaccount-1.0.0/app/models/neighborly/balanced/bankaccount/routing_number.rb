module Neighborly::Balanced::Bankaccount
  class RoutingNumber < ActiveRecord::Base
    self.table_name = :routing_numbers
    validates :number, :bank_name, presence: true
  end
end
