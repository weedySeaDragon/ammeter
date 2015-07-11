require 'rspec/expectations'
if RSpec::Expectations::Version::STRING < '3'

  { :match_when_negated => :match_for_should_not,
    :failure_message => :failure_message_for_should,
    :failure_message_when_negated => :failure_message_for_should_not
  }.each do |rspec3_method, rspec2_method|
    RSpec::Matchers::DSL::Matcher.send :alias_method, rspec3_method, rspec2_method
  end

  module RSpec2CoreMemoizedHelpers
    def is_expected
      expect(subject)
    end
  end
  if !defined? RSpec::Core::MemoizedHelpers
    module RSpec
      module Core
        module MemoizedHelpers
        end
      end
    end
  end
  RSpec::Core::MemoizedHelpers.extend RSpec2CoreMemoizedHelpers


end