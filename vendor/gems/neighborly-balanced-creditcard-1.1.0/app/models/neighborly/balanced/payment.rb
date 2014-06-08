module Neighborly::Balanced
  class Payment
    def initialize(engine_name, customer, contribution, attrs = {})
      @engine_name  = engine_name
      @customer     = customer
      @contribution = contribution
      @attrs        = attrs
    end

    def checkout!(card)
      @charge = Stripe::Charge.create(amount:     contribution_amount_in_cents,
                             currency: "cad",
                             customer: @customer.id,
                             card: card,
                             description: debit_description)
    rescue Balanced::PaymentRequired
      @contribution.cancel!
    else
      @contribution.confirm!
    ensure
      @contribution.update_attributes(
        payment_id:                       @charge.try(:id),
        payment_method:                   @engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: @attrs[:pay_fee]
      )
    end

    def contribution_amount_in_cents
      (fee_calculator.gross_amount * 100).round
    end

    def fee_calculator
      @fee_calculator and return @fee_calculator

      calculator_class = if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? @attrs[:pay_fee]
                           Creditcard::TransactionAdditionalFeeCalculator
                         else
                           Creditcard::TransactionInclusiveFeeCalculator
                         end

      @fee_calculator = calculator_class.new(@contribution.value)
    end

    def debit
      @charge.try(:sanitize)
    end

    def successful?
      @charge.failure_code.blank?
    end

    private
    def debit_description
      I18n.t('neighborly.balanced.creditcard.payments.dedit.description',
             project_name: @contribution.try(:project).try(:name))
    end

    def project_owner_customer
      @project_owner_customer ||= Neighborly::Balanced::Customer.new(
        @contribution.project.user, {}).fetch
    end

    def meta
      {
        payment_service_fee: fee_calculator.fees,
        payment_service_fee_paid_by_user: @attrs[:pay_fee],
        project: {
          id:        @contribution.project.id,
          name:      @contribution.project.name,
          permalink: @contribution.project.permalink,
          user:      @contribution.project.user.id
        },
        user: {
          id:        @contribution.user.id,
          name:      @contribution.user.display_name,
          email:     @contribution.user.email,
          address:   { line1:        @contribution.user.address_street,
                       city:         @contribution.user.address_city,
                       state:        @contribution.user.address_state,
                       postal_code:  @contribution.user.address_zip_code
          }
        },
        reward: {
          id:          @contribution.reward.try(:id),
          title:       @contribution.reward.try(:title),
          description: @contribution.reward.try(:description)
        }
      }
    end
  end
end
