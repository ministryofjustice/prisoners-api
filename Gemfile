source 'https://rubygems.org'
ruby '2.3.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_serializers'
gem 'api_pagination_headers'
gem 'carrierwave'
gem 'doorkeeper'
gem 'factory_girl_rails'
gem 'faker'
gem 'govuk_elements_form_builder', git: 'https://github.com/ministryofjustice/govuk_elements_form_builder.git'
gem 'govuk_elements_rails'
gem 'govuk_frontend_toolkit'
gem 'govuk_template', '0.18.0'
gem 'haml-rails'
gem 'jquery-rails'
gem 'kaminari'
gem 'omniauth-oauth2', '~> 1.3.1'
gem 'paper_trail'
gem 'pg'
gem 'rack-throttle'
gem 'rails', '~> 5.0.1'
gem 'roo-xls'
gem 'sass-rails'
gem 'secure_headers'
gem 'sentry-raven'
gem 'sidekiq'
gem 'swagger-blocks'
gem 'swagger_engine'
gem 'uglifier'
gem 'whenever', require: false

group :production, :devunicorn do
  gem 'unicorn-rails', '2.2.0'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

group :development, :test do
  gem 'awesome_print'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 3.1.0', require: false
  gem 'simplecov'
end
