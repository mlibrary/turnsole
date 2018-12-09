# frozen_string_literal: true

# require "coveralls"
# Coveralls.wear!
#
# def coverage_needed?
#   ENV['COVERAGE'] || ENV['TRAVIS']
# end
#
# if coverage_needed?
#   require 'coveralls'
#   Coveralls.wear! do
#     add_filter 'config'
#     add_filter 'lib/spec'
#     add_filter 'spec'
#     add_filter 'lib/tasks'
#   end
# end

require "bundler/setup"
require 'dotenv/load'
require "turnsole"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
