# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in low_loop.gemspec
gemspec

# Use local gems when in development.
gem 'low_event', path: '../low_event'
gem 'observers', path: '../observers'

group :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'rack'
  gem 'rack-test'
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.0'
  gem 'rubocop', require: false
end
