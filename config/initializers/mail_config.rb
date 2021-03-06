begin
  ActionMailer::Base.default 'Content-Transfer-Encoding' => 'quoted-printable'

  if Rails.env.production?
    ActionMailer::Base.smtp_settings = {
      :address        => 'smtp.sendgrid.net',
      :port           => '587',
      :authentication => :plain,
      :user_name      => ENV['SENDGRID_USERNAME'],
      :password       => ENV['SENDGRID_PASSWORD'],
      :domain         => 'raiseanaim.org',
      :enable_starttls_auto => true
    }
    ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end
