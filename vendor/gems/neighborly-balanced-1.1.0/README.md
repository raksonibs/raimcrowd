# Neighborly::Balanced

[![Build Status](https://travis-ci.org/neighborly/neighborly-balanced.png?branch=master)](https://travis-ci.org/neighborly/neighborly-balanced) [![Code Climate](https://codeclimate.com/github/neighborly/neighborly-balanced.png)](https://codeclimate.com/github/neighborly/neighborly-balanced)

## What

This is an integration between [Balanced](https://www.balancedpayments.com/) and [Neighborly](https://github.com/luminopolis/neighborly), a crowdfunding platform.

## How

Include this gem as dependency of your project, adding the following line in your `Gemfile`.

```ruby
# Gemfile
gem 'neighborly-balanced'
```

And install the migrations:

```console
$ bundle exec rake railties:install:migrations db:migrate
```

Neighborly::Balanced is a Rails Engine, integrating with your (Neighborly) Rails application with very little of effort. To turn the engine on, mount it in an appropriate route:

```ruby
# config/routes.rb
mount Neighborly::Balanced::Engine => '/balanced/', as: :neighborly_balanced
```

As you might know, Neighborly has a `Configuration` class, responsible to... project's configuration. You need to set API key secret and Marketplace ID, and you find yours acessing settings of [Balanced Dashboard](https://dashboard.balancedpayments.com/). Also you need to inform how the debit will appears on the statement.

```console
$ rails runner "Configuration.create!(name: 'balanced_api_key_secret', value: 'YOUR_API_KEY_SECRET_HERE')"
$ rails runner "Configuration.create!(name: 'balanced_marketplace_id', value: 'YOUR_MARKETPLACE_ID_HERE')"
$ rails runner "Configuration.create!(name: 'balanced_appears_on_statement_as', value: 'RaiseanAim')"
```

### Balanced Webhook

Balanced has a webhook that allow us to receive notifications of events that happen there. We execute a few things when certain events occurs, so you need to add on [Balanced Settings](https://dashboard.balancedpayments.com) the webhook with the following URL:

`http://my-neighborly.com/balanced/notifications`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Running specs

We prize for our test suite and coverage, so it would be great if you could run the specs to ensure that your patch is not breaking the existing codebase.

```
bundle exec rspec
```

## License

Licensed under the [MIT license](LICENSE.txt).