require 'bundler'
require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

require 'rubygems/version'

require 'fileutils'

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

Cucumber::Rake::Task.new(:cucumber)

task :ensure_bundler_version do
  min_version_str = '1.9.5'
  min_version = Gem::Version.new(min_version_str)
  bundler_version = Gem::Version.new(Bundler::VERSION)
  sh "bundler --version"
  raise "Bundler #{min_version-str} is a development dependency to build ammeter. Please upgrade bundler." unless bundler_version >= min_version
end

task :ensure_bundler_no_coc_prompt do
  sh "bundle config gem.coc false"
  sh "bundle config gem.mit false"
  sh "bundle config gem.test rspec"
  sh "bundle config"
end

task :ensure_bundler_ok => [:ensure_bundler_version, :ensure_bundler_no_coc_prompt]


def create_gem(gem_name)
  template_folder = "features/templates/#{gem_name}"

  Dir.chdir("./tmp") do
    sh "bundle gem #{gem_name} --no-coc"  # do not generate a code of conduct file. required so bundler does not issue an interactive prompt for this option
  end
  sh "cp '#{template_folder}/Gemfile' tmp/#{gem_name}"
  sh "cp '#{template_folder}/#{gem_name}.gemspec' tmp/#{gem_name}"
  sh "cp '#{template_folder}/Rakefile' tmp/#{gem_name}"
  #sh "mkdir -p tmp/#{gem_name}/spec"  # IS NOT PORTABLE: FAILS under WINDOWS. Use File.mkdir_p
  FileUtils.mkdir_p "tmp/#{gem_name}/spec"
  sh "cp '#{template_folder}/spec/spec_helper.rb' tmp/#{gem_name}/spec"
  Dir.chdir("./tmp/#{gem_name}") do
    Bundler.clean_system 'bundle install'
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app => :ensure_bundler_ok  do |t|
    sh "bundle exec rails new ./tmp/example_app -m 'features/templates/generate_example_app.rb' --skip-test-unit"
    sh "cp 'features/templates/rspec.rake' ./tmp/example_app/lib/tasks"
    Dir.chdir("./tmp/example_app/") do
      Bundler.clean_system 'bundle install'
      Bundler.clean_system 'rake db:migrate'
      Bundler.clean_system 'rails g rspec:install'
    end
  end

  desc "generate a fresh gem that depends on railties"
  task :railties_gem => :ensure_bundler_ok do |t|
    create_gem('my_railties_gem')
  end

  desc "generate a fresh gem that depends on rails"
  task :rails_gem => :ensure_bundler_ok do |t|
    create_gem('my_rails_gem')
  end
end

task :generate => [:'generate:app', :'generate:railties_gem',  :'generate:rails_gem']

namespace :clobber do
  desc "clobber the generated app"
  task :app do
    rm_rf "tmp/example_app"
  end
  task :gem do
    rm_rf "tmp/my_railties_gem"
    rm_rf "tmp/my_rails_gem"
  end
end
task :clobber => [:'clobber:app', :'clobber:gem']

task :ci => [:spec, :clobber, :generate, :cucumber]
task :default => :ci
