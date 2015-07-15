source "http://rubygems.org"

rspec_version = ENV['RSPEC_VERSION']
rspec_major_version = (rspec_version && rspec_version != 'master') ? rspec_version.scan(/\d+/).first : '3'

group :development, :test do
  if rspec_version == 'master'
    gem "rspec-rails", :git => 'git://github.com/rspec/rspec-rails.git'
    gem "rspec", :git => 'git://github.com/rspec/rspec.git'
    gem "rspec-core", :git => 'git://github.com/rspec/rspec-core.git'
    gem "rspec-expectations", :git => 'git://github.com/rspec/rspec-expectations.git'
    gem "rspec-mocks", :git => 'git://github.com/rspec/rspec-mocks.git'
    gem "rspec-collection_matchers", :git => 'git://github.com/rspec/rspec-collection_matchers.git'
    gem "rspec-support", :git => 'git://github.com/rspec/rspec-support.git'
  else
    gem 'rspec-rails', rspec_version
    gem 'rspec', rspec_version
  end

  gem 'aruba', '~> 0.7.4'
  #gem 'aruba', :git => 'git://github.com/cucumber/aruba.git'
end

if rspec_major_version == '2' || RUBY_VERSION.to_f < 1.9
  # rspec 2.x does not support Rails 4.1+ nor does Ruby 1.8.7
  gem 'rails', '~> 3.2'
  gem 'rake', '~> 0.9.2.2'
  gem 'execjs', '~> 2.0.0'

  group :assets do
    gem 'uglifier', '~> 1.2.4'
    gem 'coffee-rails', '~> 3.2'
    gem 'sass-rails', '~> 3.2'
    gem 'jquery-rails', '~> 2.0'
    gem 'haml-rails', '~> 0.4'
  end

elsif rspec_major_version == '3'
  gem 'rails', '>= 4.0'
  gem 'rake', '>= 0.10'

  group :assets do
    gem 'uglifier', '>= 1.3'
    gem 'coffee-rails', '>= 4.0'
    gem 'sass-rails', '>= 4.0'
    gem 'jquery-rails', '>= 3.0'
    gem 'haml-rails', '>= 0.5'
  end
else
  raise "rspec version #{rspec_version} is not supported"
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data' # trying this for all platforms so it will run ok on Travis-CI
# , platforms: [:mingw, :mswin, :x64_mingw] #, :jruby]

gem "i18n", '< 0.7.0' if RUBY_VERSION < '1.9.3'

gemspec