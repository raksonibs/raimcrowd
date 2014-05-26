require 'sidekiq'

module Neighborly::Balanced::Bankaccount
  class DebitAuthorizedContributionsWorker
    include Sidekiq::Worker
    sidekiq_options retry: true

    def perform(contributor_id)
      contributor = Neighborly::Balanced::Contributor.find(contributor_id)
      DelayedPaymentProcessing.new(
        contributor,
        waiting_confirmation_contributions(contributor)
      ).complete
    end

    def waiting_confirmation_contributions(contributor)
      contributor.user.contributions.
        with_state(:waiting_confirmation).
        where(payment_method: 'balanced-bankaccount')
    end
  end
end
