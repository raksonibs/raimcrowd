require 'ffaker'

# Disable sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!

def lorem_pixel_url(size = '100/100', type = 'city')
  "http://jpg-lorem-pixel.herokuapp.com/#{type}/#{size}/image.jpg"
end

def generate_user
  u = User.new name: Faker::Name.name,
               email: Faker::Internet.email,
               remote_uploaded_image_url: lorem_pixel_url('150/150', 'people')
  u.skip_confirmation!
  u.save
  u
end

def generate_project(fields = {})
   p = Project.create!({ user: User.where(email: 'org@org.com').first,
                     category: Category.order('RANDOM()').limit(1).first,
                     name: Faker::Lorem.sentence(2),
                     about: Faker::Lorem.paragraph(10),
                     headline: Faker::Lorem.sentence,
                     goal: [40000, 73000, 1000, 50000, 100000].shuffle.first,
                     online_date: Time.now,
                     online_days: [50, 90, 43, 87, 34].shuffle.first,
                     how_know: Faker::Lorem.sentence,
                     video_url: 'http://vimeo.com/79833901',
                     home_page: true,
                     address_city: Faker::Address.city, 
                     address_state: Faker::AddressUS.state_abbr,
                     remote_uploaded_image_url: lorem_pixel_url('500/400', 'city'),
                     remote_hero_image_url: lorem_pixel_url('1280/600', 'city')
    }.merge!(fields))

   [3, 5, 7].shuffle.first.times { Reward.create! project: p, minimum_value: [10, 20, 30, 40, 50, 60, 70].shuffle.first, title: Faker::Lorem.sentence, description: Faker::Lorem.paragraph(2) }
   p
end

def generate_contribution(project, fields: {}, reward: true)
  r = project.rewards.order('RANDOM()').limit(1).first if reward
  c = Contribution.create!( { project: project, user: generate_user, reward: r, value: r.minimum_value}.merge!(fields) )
  c.update_column(:state, 'confirmed')
  c
end

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
  google_analytics_id: 'SOMETHING',
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
               password: 'password',
               remote_uploaded_image_url: lorem_pixel_url('150/150', 'people')
  u.admin = true
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Test user...'

  User.new admin: false,
           name: 'Test',
           email: 'test@test.com',
           password: 'password',
           remote_uploaded_image_url: lorem_pixel_url('150/150', 'people')
  u.admin = true
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Organization user...'

  u = User.new email: 'org@org.com',
               password: 'password',
               profile_type: 'organization',
               organization_attributes: { name: 'Organization Name', remote_image_url: lorem_pixel_url('300/150', 'bussines') }
  u.admin = true
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Channel user...'

  u = User.new name: 'Channel',
               email: 'channel@channel.com',
               password: 'password',
               profile_type: 'channel'
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

puts 'Creating channel...'

  c = Channel.create! user: User.where(email: 'channel@channel.com').first,
                      name: 'Channel Name',
                      permalink: 'channel',
                      description: Faker::Lorem.paragraph,
                      remote_image_url: lorem_pixel_url('600/300', 'bussines')
  c.push_to_online!

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating channel projects...... It can take a while... You can go and get a coffee now!'

  3.times do
    p = generate_project(channels: [Channel.order('RANDOM()').limit(1).first])
    p.launch!
  end

  channel_project = Project.first
  channel_project.push_to_draft!
  channel_project.reject!
  channel_project.push_to_draft!
  channel_project.launch!
  channel_project.update_column(:recommended, true)

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating successfull projects...... It can take a while...'

  6.times do
    p = generate_project(state: 'online', goal: 1000, online_days: [30, 45, 12].shuffle.first)
    [4, 7, 15, 30].shuffle.first.times { generate_contribution(p) }
    p.update_attributes( { state: :successful, online_date: (Time.now - 50.days) })
  end

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating failed projects...... It can take a while...'

  2.times do
    p = generate_project(state: 'online', goal: 100000, campaign_type: 'all_or_none')
    [4, 7, 15, 30].shuffle.first.times { generate_contribution(p) }
    p.update_column(:state, :failed)
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating online projects all_or_none...... It can take a while...'

  2.times do
    p = generate_project(state: 'online', campaign_type: 'all_or_none')
    [4, 7].shuffle.first.times { generate_contribution(p) }
  end

puts '---------------------------------------------'
puts 'Done!'



puts 'Creating online projects...... It can take a while...'

  5.times do
    p = generate_project(state: 'online')
    [4, 3, 5, 23].shuffle.first.times { generate_contribution(p) }
  end
  p = Project.last
  p.update_column(:featured, true)

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating soon projects ...... It can take a while...'

  4.times do
    generate_project(state: 'soon')
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating ending soon projects ...... It can take a while...'

  2.times do
    p = generate_project(state: 'online', online_days: 14)
    p.update_column(:online_date, Time.now - 10.days)
  end

puts '---------------------------------------------'
puts 'Done!'

