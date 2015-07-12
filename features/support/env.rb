require 'aruba/cucumber'
require 'rake'
require 'rake/file_utils'

=begin

change made to aruba
  C:\rubys\ruby-2.1.6-p336-x64\lib\ruby\gems\2.1.0\gems\aruba-0.7.4\lib\aruba\processes\spawn_process.rb

 def run!
        @process = ChildProcess.build(*Shellwords.split(@cmd))

        # Windows needs to prepend commands with 'cmd.exe /c' @see from https://github.com/jarib/childprocess/issues/59
        @process = ChildProcess.build(*(Shellwords.split(@cmd).unshift("cmd.exe", "/c"))) if ChildProcess.windows?

=end

Before do
  if RUBY_VERSION == "1.9.3" || Gem.win_platform?   # TODO Gem.win_platform? depends on rubygems (MRI >=1.9)
    @aruba_timeout_seconds = 60
  else
    @aruba_timeout_seconds = 30
  end
end

def aruba_path(file_or_dir, source_foldername)
  File.expand_path("../../../#{file_or_dir.sub(source_foldername,'aruba')}", __FILE__)
end

def example_app_path(file_or_dir)
  File.expand_path("../../../#{file_or_dir}", __FILE__)
end

# Create a symbolic link from the file_or_dir  in the source directory (source_foldername)to
# the directory aruba uses. If no filename is given, link the entire source directory.
# This is done so that the filesystem is not full of copied files; it is just full of symbolic links.
# Note that FileUtils.safe_ln is a rake/file_utils method. If the current system does not support
# links, then copy (cp) is used.
#
# @param file_or_dir - the source file or directory
# @param source_foldername - the source directory
# @param filename=nil - a specific filename to link (optional)
# @return The result of creating the link with
def write_symlink(file_or_dir, source_foldername, filename=nil)
  source = example_app_path(file_or_dir)
  target = aruba_path(file_or_dir, source_foldername)
  target = File.join(File.dirname(target), filename) if filename
  system "ln -s #{source} #{target}"  # symbolic links are not platform safe. (not implemented on all platforms)
  #FileUtils.cp_r(source, target)
end

def copy_to_aruba_from(gem_or_app_name)
  steps %Q{
    Given a directory named "spec"
  }

  rspec_version = ENV['RSPEC_VERSION']
  rspec_major_version = (rspec_version && rspec_version != 'master') ? rspec_version.scan(/\d+/).first : '3'

  Dir["tmp/#{gem_or_app_name}/*"].each do |file_or_dir|
    if !(file_or_dir =~ /\/spec$/)
      write_symlink(file_or_dir, gem_or_app_name)
    end
  end

  write_symlink("tmp/#{gem_or_app_name}/spec/spec_helper.rb", gem_or_app_name)

  if rspec_major_version == '2'
    # rspec 2.x does not create rails_helper.rb so we create a symlink to avoid cluttering tests
    write_symlink("tmp/#{gem_or_app_name}/spec/spec_helper.rb", gem_or_app_name, 'rails_helper.rb')
  elsif rspec_major_version == '3' && File.exist?("tmp/#{gem_or_app_name}/spec/rails_helper.rb")
    write_symlink("tmp/#{gem_or_app_name}/spec/rails_helper.rb", gem_or_app_name)
  end
end

Before '@example_app' do
  copy_to_aruba_from('example_app')
end

Before '@railties_gem' do
  copy_to_aruba_from('my_railties_gem')
end

Before '@rails_gem' do
  copy_to_aruba_from('my_rails_gem')
end
