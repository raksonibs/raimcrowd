require 'observer'

module Neighborly::Balanced
  class Event
    extend Observable

    TYPES = %w(debit.created
               debit.succeeded
               bank_account_verification.verified
               bank_account_verification.deposited)

    def initialize(request_params)
      @request_params = request_params
    end

    def save
      if contribution.present?
        PaymentEngine.create_payment_notification(
          contribution_id: contribution.id,
          extra_data:      @request_params[:registration].to_json
        )
      end

      self.class.changed
      self.class.notify_observers(self)
    end

    def valid?
      valid_type? or return false

      {
        'debit.created'                       => -> { values_matches? },
        'debit.succeeded'                     => -> { values_matches? },
        'debit.canceled'                      => -> { values_matches? },
        # Skip validation for these types
        'bank_account_verification.deposited' => -> { true },
        'bank_account_verification.verified'  => -> { true }
      }.fetch(type).call
    end

    def contribution
      return false unless @request_params.try(:[], :entity).try(:[], :id)

      Contribution.find_by(payment_id: @request_params.fetch(:entity).fetch(:id))
    end

    def type
      @request_params.fetch(:type)
    end

    def entity_uri
      @request_params.fetch(:entity).fetch(:uri)
    end

    def contributor
      Neighborly::Balanced::Contributor.find_by(bank_account_uri: bank_account_uri)
    end

    def user
      contributor.try(:user) || contribution.try(:user)
    end

    protected

    def valid_type?
      TYPES.include? type
    end

    def values_matches?
      contribution.try(:price_in_cents).eql?(payment_amount)
    end

    def payment_amount
      @request_params.fetch(:entity).fetch(:amount).to_i
    end

    def verification?
      !!type['bank_account_verification']
    end

    def bank_account_uri
      if verification?
        uri = entity_uri.match(/\A(?<bank_account_uri>\/.+\/bank_accounts\/.+)\/verifications/)[:bank_account_uri]
        uri['/bank_accounts'] = "/marketplaces/#{Configuration[:balanced_marketplace_id]}/bank_accounts"
        uri
      end
    end
  end
end
