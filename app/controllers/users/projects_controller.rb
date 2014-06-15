class Users::ProjectsController < ApplicationController
  inherit_resources
  actions :index
  belongs_to :user

  def collection
    @projects ||= end_of_association_chain.without_state("deleted")
  end
end
