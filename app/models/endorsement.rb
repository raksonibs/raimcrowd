class Endorsement < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_uniqueness_of :user_id, :scope => [:project_id]
  validates_presence_of :user_id

  scope :by_project, ->(project) { where(project_id: project) }
end
