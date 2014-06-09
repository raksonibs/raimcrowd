class Companies::ContactsController < ApplicationController
  inherit_resources
  defaults class_name: 'CompanyContact'
  actions :new, :create

  def create
    create! do
      flash.notice = t('controllers.companies.contacts.create.success'
      redirect_to root_path
    end
  end

  protected
  def permitted_params
    params.permit({ company_contact: CompanyContact.attribute_names.map(&:to_sym) })
  end
end
