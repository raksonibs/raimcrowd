module Neighborly::Balanced::Bankaccount
  class Payment < PaymentBase
    def checkout!
      @debit = @customer.debit(amount:     contribution_amount_in_cents,
                               source_uri: debit_resource_uri,
                               appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as],
                               description: debit_description,
                               on_behalf_of_uri: project_owner_customer.id,
                               meta: meta)
      @contribution.confirm!
    rescue Balanced::BadRequest
      @status = :failed
      @contribution.cancel!
    ensure
      @contribution.update_attributes(
        payment_id:                       @debit.try(:id),
        payment_method:                   @engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: @attrs[:pay_fee]
      )
    end

    def successful?
      %i(pending succeeded).include? status
    end

    def debit_resource_uri
      @attrs.fetch(:use_bank) { contributor.bank_account_uri }
    end

    def contributor
      @contributor ||= Neighborly::Balanced::Contributor.find_by(uri: @customer.uri)
    end

    private
    def debit_description
      I18n.t('neighborly.balanced.bankaccount.payments.debit.description',
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
