# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

TEST_EXAMPLES_FOLDER = File.join(File.dirname(__FILE__), "examples")

if ENV['TEST_ENV'] != 'guard'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    coverage_dir "tmp/coverage"
  end
  puts "required simplecov"
end

require 'pry-byebug'
require 'minitest/autorun'
require 'minitest/color'
require 'minitest/profile'
require 'faker'
require 'pp'
require 'archimate'
require_relative 'examples/factories'

config = Archimate::Config.instance
config.interactive = false
test_log_stringio = StringIO.new
config.logger = Logger.new(test_log_stringio)

Minitest::Test.make_my_diffs_pretty!

module Minitest
  class Test
    include Archimate::Examples::Factories
    include Archimate::DataModel::DiffableArray
    include Archimate::DataModel::DiffablePrimitive
  end
end
