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
    @endorsment = Endorsement.new({project: parent, user: current_user})
    if @endorsment.save
      redirect_to project_path(parent)
    else
      redirect_to project_path(parent)
    end
  end


  protected
  def permitted_params
    params.permit(policy(@endorsment || Contribution).permitted_attributes)
  end

  def collection
    @endorsments ||= apply_scopes(end_of_association_chain).available_to_display.order("confirmed_at DESC").per(10)
  end
end
