#!/usr/bin/env ruby

require "fileutils"
include FileUtils

commands = [
  'mysql -e "create user rails@localhost;"',
  'mysql -e "grant all privileges on activerecord_unittest.* to rails@localhost;"',
  'mysql -e "grant all privileges on activerecord_unittest2.* to rails@localhost;"',
  'mysql -e "grant all privileges on inexistent_activerecord_unittest.* to rails@localhost;"',
  'mysql -e "create database activerecord_unittest default character set utf8mb4;"',
  'mysql -e "create database activerecord_unittest2 default character set utf8mb4;"',
  'psql  -c "create database -E UTF8 -T template0 activerecord_unittest;" -U postgres',
  'psql  -c "create database -E UTF8 -T template0 activerecord_unittest2;" -U postgres'
]

commands.each do |command|
  system(command)
end

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "activerecord"
  gem "pg"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "activerecord_unittest")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 1, post.comments.count
    assert_equal 1, Comment.count
    assert_equal post.id, Comment.first.post.id
  end
end
