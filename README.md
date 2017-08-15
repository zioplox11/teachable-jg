# Teachable::Jg

A module for accessing valid endpoints of the Teachable Mock API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'teachable-jg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teachable-jg

To install using Bundler grab the latest stable version:

gem 'teachable-jg', '~> 0.0.8'

## Usage

Use this gem to as a wrapper to easily register and authorize users, create, pull, and delete orders via the Teachable Mock API.

Some handy methods at your disposal one you're authorized:

client = Teachable::Jg::Client.new(email: , password: )

if client.authorized is true, you then have access methods such as

'user_info,' 'create_order,' 'delete_orders,' 'orders'

You can also register a new user easily by passing "registration: true" along with email and password when initializing a client.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. If 'bin/console' causes trouble, try 'rake console' instead.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/teachable-jg/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
