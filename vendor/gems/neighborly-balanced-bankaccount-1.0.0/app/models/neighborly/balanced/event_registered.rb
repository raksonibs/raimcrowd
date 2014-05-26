module Neighborly::Balanced
  class EventRegistered
    def confirm(event)
      case event.type
      when 'bank_account_verification.deposited'
        Notification.notify('balanced/bankaccount/confirm_bank_account', event.user)
      when 'bank_account_verification.verified'
        verification = Neighborly::Balanced::Bankaccount::Verification.find(event.entity_uri)
        verification.confirm
      end
    end
  end
end
