require 'rails/generators'
require 'active_support/core_ext'
require 'action_view'
require 'action_view/template'
require 'action_pack'
require 'action_controller'

require 'rspec/rails'
require 'rspec/rails/example'

require 'ammeter/rspec/generator/example/generator_example_group'


RSpec::configure do |c|
  def c.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]') + '[\\\/]')
  end

  generator_path_regex = c.escaped_path(%w[spec generators])
  if RSpec::Core::Version::STRING >= '3'
    c.include Ammeter::RSpec::Rails::GeneratorExampleGroup,
      :type          => :generator,
      :file_path     => lambda { |file_path, metadata|
        metadata[:type].nil? && generator_path_regex =~ file_path
      }

  else #rspec2

    c.include Ammeter::RSpec::Rails::GeneratorExampleGroup, :type => :generator, :example_group => {
      :file_path => generator_path_regex
    }
  end

end
