class Projects::EndorsementsController < ApplicationController
  # after_filter :verify_authorized, except: :index
  inherit_resources
  skip_before_filter :verify_authenticity_token, only: [:moip]
  skip_before_filter :set_persistent_warning
  has_scope :available_to_count, type: :boolean
  has_scope :with_state
  has_scope :page, default: 1
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render collection
    end
  end

  def edit
    authorize resource
  end

  def show
    authorize resource
  end

  def new
    @endorsment = Endorsement.new(project: parent, user: current_user)
  end

  def create
    @endorsement = Endorsement.new({user: current_user,
                                           project: parent})
    create! do |success, failure|
      success.html do
          flash[:notice] = t('success', scope: 'controllers.projects.endorsements.success')
          return redirect_to main_app.project_endorsement_path(
            @endorsement.project.permalink,
            @endorsement.id
          )
      end

      failure.html do
        return redirect_to new_project_contribution_path(@project), flash: { failure: t('controllers.projects.endorsements.failure') }
      end
    end
  end


  protected
  def permitted_params
    params.permit(policy(@endorsment || Endorsement).permitted_attributes)
  end

  def collection
    @endorsments ||= Endorsement.by_project(parent.id)
  end
end
