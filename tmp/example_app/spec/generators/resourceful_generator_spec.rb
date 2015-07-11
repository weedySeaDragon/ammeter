require "rails_helper"
require 'generators/resourceful/resourceful_generator'

describe ResourcefulGenerator do
  before { run_generator %w(post) }
  describe 'app/controller/posts_controller.rb' do
    subject { file('app/controllers/posts_controller.rb') }
    it { expect(subject).to exist }
    it { expect(subject).to contain 'class PostsController < ResourcefulController' }
  end

  describe 'app/models/post.rb' do
    subject { file('app/models/post.rb') }
    it { expect(subject).to exist }
    it { expect(subject).to contain 'class Post < ActiveRecord::Base' }
  end
end