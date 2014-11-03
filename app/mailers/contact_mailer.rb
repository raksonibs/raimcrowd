class ContactMailer < ActionMailer::Base

  def send_contact(contact)
    @contact = contact
    @url  = 'http://example.com/login'
    mail(to: 'contact@raiseanaim.org', from: @contact[:email], subject: 'Welcome to My Awesome Site')
  end
  # {"first_name"=>"test",
   # "last_name"=>"test",
   # "email"=>"test@test.com",
   # "phone"=>"test",
   # "company_name"=>"test",
   # "company_website"=>"teest",
   # "message"=>"test"},

end
