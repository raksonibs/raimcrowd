module Neighborly::Balanced::Bankaccount
  class PaymentGenerator
    attr_reader :attrs, :contribution, :customer

    delegate :status, to: :payment

    def initialize(customer, contribution, attrs = {})
      @customer      = customer
      @contribution  = contribution
      @attrs         = attrs
    end

    def complete
      payment.checkout!
    end

    def payment
      @payment ||= payment_class.new(
        'balanced-bankaccount',
        customer,
        contribution,
        attrs
      )
    end

    def payment_class
      @payment_class ||= can_debit_resource? ? Neighborly::Balanced::Bankaccount::Payment : Neighborly::Balanced::Bankaccount::DelayedPayment
    end

    def can_debit_resource?
      debit_resource.verifications.first.try(:state).eql? 'verified'
    end

    def debit_resource
      @debit_resource ||= ::Balanced::BankAccount.find(@attrs.fetch(:use_bank))
    end
  end
end
