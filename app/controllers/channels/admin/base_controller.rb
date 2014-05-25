module Channels::Admin
  class BaseController < ApplicationController
    inherit_resources

    before_filter do
      # puts "CHANNEL: #{channel}"
      # authorize channel, :admin?
    end
  end
end
