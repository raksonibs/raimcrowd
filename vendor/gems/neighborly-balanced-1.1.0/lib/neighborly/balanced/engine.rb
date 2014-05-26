module Neighborly
  module Balanced
    class Engine < ::Rails::Engine
      isolate_namespace Neighborly::Balanced

      config.autoload_paths += Dir["#{config.root}/app/observers/**/"]

      initializer 'include_user_concern' do |app|
        ::User.send(:include, Neighborly::Balanced::User)
      end
    end
  end
end
