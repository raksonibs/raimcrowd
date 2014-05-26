events_observer_debit_canceled = Neighborly::Balanced::EventsObserver::DebitCanceled.new
Neighborly::Balanced::Event.add_observer(events_observer_debit_canceled, :perform)
