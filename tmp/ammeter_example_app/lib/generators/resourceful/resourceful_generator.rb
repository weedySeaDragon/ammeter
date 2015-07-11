class ResourcefulGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  class_option :super, :type => :boolean, :default => false

  hook_for :orm, :in => :rails, :as => :model, :required => true

  def create_resourceful_controller
    template 'controller.rb', File.join('app/controllers',  "#{plural_file_name}_controller.rb")
  end
end