class Users::EndorsementssController < ApplicationController
  inherit_resources
  belongs_to :user

  def new
    @project = Project.find(params[:project_id])

    unless current_user
      return redirect_to new_user_session_path
    end
    @user = parent
    render layout: false
  end

  def create
    project = Project.find(params[:project_id])
    unless current_user
      return redirect_to new_user_session_path
    end
    
    flash.notice = "nice endorsement."
    redirect_to project_path(project)
  end
end
