module Neighborly::Balanced
  class Error         < StandardError; end
  class NoBankAccount < Error;         end

  class Payout
    def initialize(project, requestor_user)
      @project   = project
      @requestor = requestor_user
    end

    def complete!
      if customer.bank_accounts.empty?
        raise NoBankAccount, 'The customer doesn\'t have a bank account to credit.'
      end

      customer.credit(amount: amount_in_cents)
      ::Payout.create(
        payment_service: 'balanced',
        project_id:      @project,
        user_id:         @requestor,
        value:           amount
      )
    end

    def amount
      ProjectFinancialsByService.
        where(project_id: @project).
        where("payment_method LIKE 'balanced-%'").
        sum(:net_amount)
    end

    def customer
      neighborly_customer.fetch
    end

    def neighborly_customer
      @neighborly_customer ||= Neighborly::Balanced::Customer.new(@project.user, {})
    end

    protected

    def amount_in_cents
      (amount * 100).round
    end
  end
end
