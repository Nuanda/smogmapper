source 'https://rubygems.org'

# This declaration is required for proper Heroku deployment
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0'
# Use HAML for view templates
gem 'haml-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '2.6.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'oj'
gem 'oj_mimic_json'

# This source allows us use bower.io js packages as gems
source 'https://rails-assets.org' do
  # A rails-assets 'gem' section, downloaded and packaged from bower.io
  # That packages the leaflet.js library for maps handling
  gem 'rails-assets-leaflet', '1.0.0.beta.2'
  # It's an extension for leaflet.js to deal with ArcGIS feature layer servers
  gem 'rails-assets-esri-leaflet', '~> 1.0.0'
end

# Helps with translating strings directly in js/cs
gem 'i18n-js'
# For Rails route helpers in js/cs code
gem 'js-routes'

# Use jQuery as the JavaScript library
gem 'jquery-rails', '~> 4.0.0'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Fixes problem with JS stopped working after switching page using turbolins
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-sass', '~> 4.2'
gem 'autoprefixer-rails'
gem 'devoops-rails',
    github: 'mkasztelnik/devoops-rails',
    branch: 'v2'

# # GEO section
# gem 'rgeo'
# # rgeo extensions for geoJSON API
# gem 'rgeo-geojson'
# # The activerecord-postgis-adapter is the database adapter that will be using instead of the normal postgresql adapter.
# gem 'activerecord-postgis-adapter', github: 'barelyknown/activerecord-postgis-adapter', branch: 'rails-4-1'

group :development do
  gem 'quiet_assets'

  gem 'pry-rails'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Loading environment variables from .env
  gem 'dotenv-rails'

  # specs
  gem 'rspec-rails', '~> 3.0'
end

group :test do
  # specs
  gem 'spring-commands-rspec'
  gem 'capybara'

  # model factories
  gem 'factory_girl_rails', '~> 4.0'

  # additional matchers
  gem 'shoulda-matchers', require: false

  # automatically invoke spec after clicking ctr+s
  gem 'guard-rspec', require: false
  gem 'guard-spring'

  # run spec inside transaction rollbacked ad the end
  gem 'database_cleaner'

  # fake data generator
  gem 'faker'
end

group :production do
  gem 'rails_12factor'
  #gem 'unicorn'
  gem 'puma'
end
