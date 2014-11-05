class EndorsementPolicy < ApplicationPolicy
  def permitted_attributes
    {endorsment: record.attribute_names.map(&:to_sym) - %i[
                                                             user_id
                                                             project_id]}
  end
end
