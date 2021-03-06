# Disable sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!

puts 'Creating Configuration entries...'

  {
    company_name: 'raiseanaim.org',
    host: 'raiseanaim.org',
    base_url: 'http://raiseanaim.org',
    blog_url: 'http://blog.raiseanaim.org',
    base_domain: 'raiseanaim.org',
    email_contact: 'contact@raiseanaim.org',
    email_payments: 'books@raiseanaim.org',
    email_system: 'no-reply@raiseanaim.org',
    email_no_reply: 'no-reply@raiseanaim.org',
    facebook_url: 'https://www.facebook.com/raimcanada',
    facebook_app_id: '764971740235673',
    twitter_username: 'raimcanada',
    platform_fee: 0.05,
    support_forum: 'http://neighborly.uservoice.com/',
    project_finish_time: '02:59:59',
    secret_token: SecureRandom.hex(64),
    secret_key_base: SecureRandom.hex(64),
    currency_charge: 'CAD',
    google_analytics_id: 'UA-56569850-1',
    email_projects: 'ideas@raiseanaim.org',
    timezone: 'US/Central',
    devise_secret_key: SecureRandom.hex(64),
    balanced_api_key_secret: 'YOUR_API_KEY_SECRET_HERE',
    balanced_marketplace_id: 'YOUR_MARKETPLACE_ID_HERE',
    aws_bucket: "raiseanaim",
    aws_access_key: "AKIAIMQJQOG2A3LO6JHQ",
    aws_secret_key: "VWJqa8p0z5CbvzqkdKB/8EB7pJIqLmDZzjVU53zC"
  }.each do |name, value|
     Configuration[name] = value
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating State entries...'

  [[name: "Alberta", acronym: "AB"],
  [name: "British Columbia", acronym: "BC"],
  [name: "Manitoba", acronym: "MB"],
  [name: "New Brunswick", acronym: "NB"],
  [name: "Newfoundland and Labrador", acronym: "NL"],
  [name: "Nova Scotia", acronym: "NS"],
  [name: "Northwest Territories", acronym: "NT"],
  [name: "Nunavut", acronym: "NU"],
  [name: "Ontario", acronym: "ON"],
  [name: "Prince Edward Island", acronym: "PE"],
  [name: "Quebec", acronym: "QC"],
  [name: "Saskatchewan", acronym: "SK"],
  [name: "Yukon", acronym: "YT"]].each do |item|
    State.create! item
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating OauthProvider entries...'

  categories = %w{facebook twitter google_oauth2 linkedin}
  oauth_providers = {
    "facebook" => {:key => Figaro.env.facebook_app_id, :secret => Figaro.env.facebook_app_secret},
    "twitter" => {:key => Figaro.env.twitter_app_id, :secret => Figaro.env.twitter_app_secret},
    "google_oauth2" => {:key => Figaro.env.google_oauth2_app_id, :secret => Figaro.env.google_oauth2_app_secret},
    "linkedin" => {:key => Figaro.env.linkedin_app_id, :secret => Figaro.env.linkedin_app_secret, :scope => "r_basicprofile"}
  }
  
  categories.each do |name|
    OauthProvider.create! name: name, path: name, secret: Figaro.env.send(name+"_app_secret"), key: Figaro.env.send(name+"_app_id")
  end

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating Category entries...'

  categories = %w{Transit Bicycling Technology Entertainment Sports Recreation Schools Streetscapes Environment Restoration Event Mobility}
  categories.each do |c|
    Category.create! name_pt: c, name_en: c
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Admin user...'
  u = User.new name: 'Admin',
               email: 'admin@admin.com',
               password: 'password'
  u.admin = true
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating system users...'

  # User to receive company contact notifications
  u = User.new email: Configuration[:email_contact], password: SecureRandom.hex(4)
  u.skip_confirmation!
  u.confirm!
  u.save

  # User to receive new projects on draft notifications
  u = User.new email: Configuration[:email_projects], password: SecureRandom.hex(4)
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'
