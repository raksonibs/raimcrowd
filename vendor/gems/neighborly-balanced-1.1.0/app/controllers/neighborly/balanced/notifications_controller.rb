module Neighborly::Balanced
  class NotificationsController < ApplicationController
    def create
      event = Event.new(params)
      event.save

      status = event.valid? ? :ok : :bad_request
      render nothing: true, status: status
    end
  end
end
