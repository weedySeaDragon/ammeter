require 'bundler'
require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

require 'rubygems/version'

require 'fileutils'


TASK_SEPARATOR = "\n\n=======================================================================\n\n"

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

  raise "Bundler #{min_version-str} is a development dependency to build ammeter. Please upgrade bundler." unless bundler_version >= min_version
end

task :ensure_bundler_no_coc_prompt do
  sh "bundle config gem.coc false"
  sh "bundle config gem.mit false"
  sh "bundle config gem.test rspec"
end

task :ensure_bundler_ok => [:ensure_bundler_version, :ensure_bundler_no_coc_prompt]

# templates used to create temporary example files for gems and app (hardcoded files were out of sync/diverging from each other and brittle)
namespace :prep_templates do

  task :app do

  end


  def gem_rakefile
    rakefile_contents = <<-'EOS'
#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec'
require 'rspec/core/rake_task'
desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end
    EOS
  end


  def gem_gemfile

  end


  def gem_spec_helper

  end


  def gem_gemspec

  end


  task :rails_gem do

  end

  task :railties_gem do

  end
end


def gemspec_testfiles
  "test_files    = gem.files.grep(%r{^(test|spec|features)/})"
end


# make a string for a runtime dependency, suitable for putting into a gemspec file
def gemspec_runtime_dependency(gemname, options='')
  "add_runtime_dependency    '#{gemname}'" << (options.empty? ? '' : ", '#{options}'")
end


# TODO write a test for the gemspec_sub ...
# find the key in the gemspec file and replace the existing value with new_value
# for a value not within []s (not a list of things)
def gemspec_sub_value(key='', val_wrapper=['', ''], new_value='', source)
  new_str = ''

  search_regex = /(?<beginning_with_key>.#{key}\s*=\s*)(?<old_value>.*)(?<ending>\s*)$/ # for a value after the = (not within []s)

  if (found = search_regex.match(source))
    # wrap the new value with the val_wrapper
    new_str = "#{val_wrapper.first}#{new_value}#{val_wrapper.last}"
  end

  new_source = source.gsub("#{found[:beginning_with_key]}#{found[:old_value]}#{found[:ending]}", "#{found[:beginning_with_key]}#{new_str}#{found[:ending]}")

end


def gemspec_substitue_new_info(gem_name, gemspec_source)
  new_source = gemspec_source

  # change the name of the gem
  new_source = gemspec_sub_value('name', ['"', '"'], gem_name, new_source)

  #change authors
  new_source = gemspec_sub_value('authors', ['["', '"]'], 'Alex Rothenberg', new_source)

  #change email
  new_source = gemspec_sub_value('email', ['["', '"]'], 'alex@alexrothenberg.com', new_source)

  #change how to get the version
  new_source = gemspec_sub_value('version', ['', ''], 'MyRailsGem::VERSION', new_source)

  new_source
end


# let bundler create the gemspec.rb file, but we need to fix it up so it will run as expected with
#  aruba and our tests
def fixup_gemspec(gem_name, runtime_dependency)

  # get the var name for the gem specification
  # Gem::Specification.new do |spec|
  # get the string from the file and do RegularExpression pattern matching

  source = <<-'EOS'
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_gem/version'

      Gem::Specification.new do |spec|
        spec.name          ="rails_spec"
        spec.version       = RailsGem::VERSION
        spec.authors       = ["Ashley Engelund (aenw / weedySeaDragon)"]
        spec.email         = ["ashley@ashleycaroline.com"]

        spec.summary       = %q{TODO: Write a short summary, because Rubyspecs requires one.}
        spec.description   = %q{TODO: Write a longer description or delete this line.}
        spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
  EOS

  new_source = gemspec_substitue_new_info(gem_name, source)

  loop_regexp = /Gem::Specification.new do \|(?<loop_var>\w*)\|(?<loop_body>.*)end/m

  gem_loop_var = (found = loop_regexp.match(new_source)) ? found[:loop_var] : 'gem'
  gemspec_config_loop_body = (found = loop_regexp.match(new_source)) ? found[:loop_body] : ''


  # add rails to the runtime dependency  TODO or railties - make a separate method
  rt_dep = "  #{gem_loop_var}.#{runtime_dependency}"

  # add test files for the gem
  t_files = "  #{gem_loop_var}.#{gemspec_testfiles}"

  # append the rails and test_files lines to the body of the Gem::Specification loop
  new_loop_body = "#{gemspec_config_loop_body}\n\n#{rt_dep}\n#{t_files}\n"

  new_source = new_source.gsub(gemspec_config_loop_body, new_loop_body) unless !found
end


task :test_sub do
  gem_name = 'my_rails_gem'
  additional_rt_dependency = gemspec_runtime_dependency('rails', '>= 3.2')
  puts "#{fixup_gemspec(gem_name, additional_rt_dependency)}"

end


def create_gem(gem_name)
  template_folder = "features/templates/#{gem_name}"

  Dir.chdir("./tmp") do
    sh "bundle gem #{gem_name} --verbose --no-coc" # no code of conduct file else bundler does interactive prompt for this option on travis-ci
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

  # sh "cp '#{template_folder}/#{gem_name}.gemspec' tmp/#{gem_name}" # has to happen after bundle actions else can get clobbered
  # sh "cp '#{template_folder}/Rakefile' tmp/#{gem_name}"
end


# copy spec/support files to example_app/spec/support
def cp_spec_support
  sh "cp -r #{File.join('.', 'spec', 'support')} #{File.join('.', 'tmp', 'example_app', 'spec', 'support')}"
end


namespace :generate do

  desc "generate a fresh app with rspec installed"
  task :app => :ensure_bundler_ok do |t|
    puts TASK_SEPARATOR
    sh "bundle exec rails new ./tmp/example_app -m 'features/templates/generate_example_app.rb' --skip-test-unit"
    sh "cp 'features/templates/rspec.rake' ./tmp/example_app/lib/tasks"

    Dir.chdir("./tmp/example_app/") do
      Bundler.clean_system 'bundle install'
      Bundler.clean_system 'rake db:migrate'
      Bundler.clean_system 'rails g rspec:install'

      ammeter_help = <<-'EOS'

# The following is added for testing ammeter

require 'ammeter/init'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |c|
    c.include MatchesForRSpecRailsSpecs
    if RSpec::Core::Version::STRING < '3'
      c.include RSpec2MemoizedHelpersCompatibility
    end
  end

  def stub_file(filename, content)
    allow(File).to receive(:read).with(filename).and_return(content)
  end

  module TestApp
    class Application < Rails::Application
      config.root = File.dirname(__FILE__)
    end
  end
      EOS

      File.open("spec/spec_helper.rb", 'a') { |f| f.write ammeter_help }

      File.open("spec/rails_helper.rb", 'a') { |f| f.write ' ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"' }

    end # Dir.chdir

    cp_spec_support
  end


  desc "generate a fresh gem that depends on railties"
  task :railties_gem => :ensure_bundler_ok do |t|
    puts TASK_SEPARATOR
    create_gem('my_railties_gem')
  end

  desc "generate a fresh gem that depends on rails"
  task :rails_gem => :ensure_bundler_ok do |t|
    puts TASK_SEPARATOR
    create_gem('my_rails_gem')
  end
end

task :gen_gems => [:'generate:railties_gem', :'generate:rails_gem']

task :generate => [:'generate:app'] #  , :'gen_gems']


namespace :clobber do

  desc "clobber the generated app"
  task :app do
    rm_rf "tmp/example_app"
  end

  desc "clobber the gems generated for rails and railties"
  task :gem do
    rm_rf "tmp/my_railties_gem"
    rm_rf "tmp/my_rails_gem"
  end

  desc "clobber the directory aruba uses for testing"
  task :aruba do
    rm_rf "tmp/aruba"
  end
end


task :clobber => [:'clobber:app', :'clobber:gem', :'clobber:aruba']


task :ci => [:spec, :clobber, :generate, :cucumber]


task :default => :ci
