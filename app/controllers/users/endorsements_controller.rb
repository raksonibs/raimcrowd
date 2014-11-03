class Users::EndorsementsController < ApplicationController
  inherit_resources
  belongs_to :user

  def index
    @project = Project.find(params[:project_id])

    unless current_user
      return redirect_to new_user_session_path
    end
    @user = parent
    render layout: false
  end
end
