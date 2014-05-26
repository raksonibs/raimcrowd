module Neighborly::Balanced
  module EventsObserver
    class DebitCanceled

      def perform(event)
        if event.type.eql? 'debit.canceled'
          event.contribution.cancel!
        end
      end

    end
  end
end
