require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  coverage_dir('coverage/')
end

require 'tugboat'
require 'webmock/rspec'
require 'digital_ocean'
require "shared/environment"

RSpec.configure do |config|
  # Pretty tests
  config.color_enabled = true

  config.order = :random
end

def project_path
  File.expand_path("../..", __FILE__)
end

def fixture(fixture_name)
  File.new(project_path + "/spec/fixtures/#{fixture_name}.json")
end

ENV["TUGBOAT_CONFIG_PATH"] = project_path + "/tmp/tugboat"
