# frozen_string_literal: true

module Turnsole
  module Heliotrope
    LICENSE_TYPES = %i[full read].freeze

    def self.encode_license_type(license_type)
      case license_type
      when :full
        "Greensub::FullLicense"
      when :read
        "Greensub::ReadLicense"
      else
        "Greensub::License"
      end
    end

    def self.decode_license_type(license_type)
      case license_type
      when "Greensub::FullLicense"
        :full
      when "Greensub::ReadLicense"
        :read
      end
    end
  end
end

#
# Require Relative
#
require_relative "./heliotrope/service"
