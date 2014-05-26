module Neighborly::Balanced::Bankaccount
  class DelayedPaymentProcessing
    def initialize(contributor, contributions)
      @contributor, @contributions = contributor, contributions
    end

    def complete
      @contributions.each do |contribution|
        Neighborly::Balanced::Bankaccount::Payment.new(
          'balanced-bankaccount',
          customer,
          contribution,
          {}
        ).checkout!
      end
    end

    def customer
      @customer ||= ::Balanced::Customer.find(@contributor.uri)
    end
  end
end
