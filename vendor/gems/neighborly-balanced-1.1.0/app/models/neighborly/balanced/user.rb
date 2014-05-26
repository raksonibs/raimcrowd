module Neighborly::Balanced::User
  extend ActiveSupport::Concern
  included do
    has_one :balanced_contributor, class_name: 'Neighborly::Balanced::Contributor'
  end
end
