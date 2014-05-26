module Neighborly::Balanced::Bankaccount
  class PaymentsController < AccountsController
    def create
      attach_bank_to_customer
      update_customer

      @contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      @payment      = Neighborly::Balanced::Bankaccount::PaymentGenerator.new(
        customer,
        @contribution,
        resource_params
      )
      @payment.complete

      redirect_to(*checkout_response_params)
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end

    protected

    def checkout_response_params
      {
        succeeded: [
          main_app.project_contribution_path(
            @contribution.project.permalink,
            @contribution.id
          )
        ],
        failed: [
          main_app.edit_project_contribution_path(
            @contribution.project.permalink,
            @contribution.id
          ),
          alert: t('.errors.default')
        ]
      }.fetch(@payment.status)
    end
  end
end
