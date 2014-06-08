module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    before_filter :authenticate_user!

    def new
      @balanced_marketplace_id = 1
      @cards                   = customer.cards
    end

    def create
      attach_card_to_customer
      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      payment      = Neighborly::Balanced::Payment.new('balanced-creditcard',
                                                       customer,
                                                       contribution,
                                                       resource_params)

      use_card = resource_params.fetch(:use_card)

      if use_card == "new"
        card = customer.cards.first.id
      else
        card = use_card
      end

      puts "USING CARD: #{card}"
      
      payment.checkout!(card)

      if payment.successful?
        flash[:success] = t('success', scope: 'controllers.projects.contributions.pay')
        redirect_to main_app.project_contribution_path(
          contribution.project.permalink,
          contribution.id
        )
      else
        flash[:alert] = t('.errors.default')
        redirect_to main_app.edit_project_contribution_path(
          contribution.project.permalink,
          contribution.id
        )
      end
    end

    private

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_card,
                    :pay_fee,
                    user: {})
    end

    def attach_card_to_customer
      credit_card = resource_params.fetch(:use_card)
      unless customer.cards.any? { |c| c.id.eql? credit_card }
        if credit_card == "new"
          customer.card = params[:stripeToken]
        end
        customer.save
      end
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end
  end
end
