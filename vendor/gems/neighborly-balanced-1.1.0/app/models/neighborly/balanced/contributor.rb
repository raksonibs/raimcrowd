module Neighborly::Balanced
  class Contributor < ActiveRecord::Base
    self.table_name = :balanced_contributors

    # The class_name is needed because Ruby tries
    # to get this User constant inside
    # Neighborly::Balanced module.
    belongs_to :user, class_name: '::User'
  end
end
