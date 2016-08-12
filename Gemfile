source 'https://rubygems.org'
ruby '2.3.0'

gem 'active_model_serializers'
gem 'carrierwave'
gem 'devise'
gem 'doorkeeper'
gem 'haml-rails'
gem 'jquery-rails'
gem 'paper_trail'
gem 'pg'
gem 'rails', '~> 5.0.0'
gem 'swagger-docs'
gem 'textacular',   '~> 4.0'

group :production, :devunicorn do
  gem 'unicorn-rails',  '2.2.0'
end

group :development do
  gem 'listen'
  gem 'web-console'
end

group :development, :test do
  gem 'awesome_print'
  gem 'byebug'
  gem 'rspec-rails'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rails-controller-testing'
  gem 'rspec-mocks'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end
