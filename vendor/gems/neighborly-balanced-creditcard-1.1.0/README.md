# Neighborly::Balanced::Creditcard

[![Build Status](https://travis-ci.org/neighborly/neighborly-balanced-creditcard.png?branch=master)](https://travis-ci.org/neighborly/neighborly-balanced-creditcard) [![Code Climate](https://codeclimate.com/github/neighborly/neighborly-balanced-creditcard.png)](https://codeclimate.com/github/neighborly/neighborly-balanced-creditcard)


## What

This is an integration between [Balanced](https://www.balancedpayments.com/) and [Neighborly](https://github.com/luminopolis/neighborly), a crowdfunding platform.

## How

Include this gem as dependency of your project, adding the following line in your `Gemfile`.

```ruby
# Gemfile
gem 'neighborly-balanced-creditcard'
```

Neighborly::Balanced::Creditcard is a Rails Engine, integrating with your (Neighborly) Rails application with very little of effort. To turn the engine on, mount it in an appropriate route:

```ruby
# config/routes.rb
mount Neighborly::Balanced::Creditcard::Engine => '/balanced/creditcard/', as: :neighborly_balanced_creditcard
```

And load our JavaScript:

```coffeescript
//= require neighborly-balanced-creditcard
```

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