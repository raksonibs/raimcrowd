event_observer = Neighborly::Balanced::EventRegistered.new
Neighborly::Balanced::Event.add_observer(event_observer, :confirm)
