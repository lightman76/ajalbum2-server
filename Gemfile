source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3', '~> 1.4'
gem 'mysql2', '~>0.5.3'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'dry-validation', '~>1.5.0'
gem 'dry-monads'
gem 'trailblazer', '~>2.1.0'
gem 'trailblazer-rails', '~>2.1.7'
gem 'reform-rails', '~>2.6.0'
gem 'roar'
gem 'multi_json'

#Gem to read EXIF (aka jpeg) metadata - IMPORTANT: Requires libexif/libexif-devel to be installed locally
gem 'exif', "~>2.2.0"

#Gem to work with imagemagick to create resized/optimized images
# IMPORTANT: This will require the imagemagick command line tools to be installed locally
gem "mini_magick"

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  #gem 'capybara', '>= 2.15'
  #gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  #gem 'webdrivers'
  gem 'rspec-rails', '~>4.0.1'
  gem 'rspec-mocks', '~>3.9.1'
  gem 'rspec-activemodel-mocks'
end

group :development, :test do
  gem 'pry'
  gem 'database_cleaner'
  gem 'guard'
  gem 'guard-rspec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
