module Neighborly::Balanced::Bankaccount
  class Verification
    delegate :user, to: :contributor

    def self.find(uri)
      new(::Balanced::Verification.find(uri))
    end

    def initialize(balanced_verification)
      @source = balanced_verification
    end

    def bank_account
      ::Balanced::BankAccount.find(bank_account_uri)
    end

    def bank_account_uri
      account_uri = uri.match(/\A(?<bank_account_uri>\/.+\/bank_accounts\/.+)\/verifications/)[:bank_account_uri]
      account_uri['/bank_accounts'] = "/marketplaces/#{Configuration[:balanced_marketplace_id]}/bank_accounts"
      account_uri
    end

    def contributor
      Neighborly::Balanced::Contributor.find_by(bank_account_uri: bank_account_uri)
    end

    def confirm
      DebitAuthorizedContributionsWorker.perform_async(contributor.id)
    end

    # Delegate instance methods to Balanced::Verification object
    def method_missing(method, *args, &block)
      if @source.respond_to? method
        @source.public_send(method, *args, &block)
      else
        super
      end
    end
  end
end
