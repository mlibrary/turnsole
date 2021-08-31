# frozen_string_literal: true

module Turnsole
  #
  # Logger
  #
  require 'logger'
  # mattr_accessor :logger
  @logger = Logger.new($stdout)

  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  #
  # Configure
  #
  @configured = false

  # spec helper
  def self.reset_configured_flag
    @configured = false
  end

  def self.configured?
    @configured
  end

  def self.configure
    @configured = true
    yield self
  end
end

#
# Require Relative
#
require_relative "./turnsole/handle"
require_relative "./turnsole/heliotrope"
require_relative "./turnsole/version"
