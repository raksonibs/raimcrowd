module Neighborly
  module Balanced
    module Bankaccount
      class Engine < ::Rails::Engine
        isolate_namespace Neighborly::Balanced::Bankaccount
        initializer 'action_controller' do |app|
          ActiveSupport.on_load :action_controller do
            helper Rails.application.helpers
          end
        end
      end
    end
  end
end
