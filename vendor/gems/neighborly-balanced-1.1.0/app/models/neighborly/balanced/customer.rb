module Neighborly::Balanced
  class Customer
    def initialize(user, request_params)
      @user = user
      @request_params = request_params
    end

    def fetch
      current_customer_uri = @user.balanced_contributor.try(:uri)
      @customer          ||= if current_customer_uri
                               Stripe::Customer.retrieve(current_customer_uri)
                             else
                               create!
                             end
    end

    def update!
      return unless user_params
      fetch.description    = "Customer for #{user_params.delete(:name)}"
      
      fetch.save
      @user.update!(user_params)
    end

    private
    def create!
      customer = Stripe::Customer.create(description:    "Customer for #{@user.display_name}",
                                          email:   @user.email)
      
      @user.create_balanced_contributor(uri: customer.id)

      customer
    end

    def user_params
      @request_params.permit(payment: [user: %i(
                                             name
                                             address_street
                                             address_city
                                             address_state
                                             address_zip_code
                                           )])[:payment][:user]
    end
  end
end
