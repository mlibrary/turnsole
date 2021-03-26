# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'json'

module Turnsole
  module Heliotrope
    class Service # rubocop:disable Metrics/ClassLength
      #
      # Product
      #
      def products
        response = connection.get('products')
        return response.body if response.success?

        []
      end

      def find_product(identifier:)
        response = connection.get("product", identifier: identifier)
        return response.body["id"] if response.success?

        nil
      end

      def create_product(identifier:, name:, purchase: "x")
        response = connection.post("products", { product: { identifier: identifier, name: name, purchase: purchase } }.to_json)
        return response.body["id"] if response.success?

        warn "Unable to create product #{identifier} - #{response.body}"
        nil
      end

      def delete_product(identifier:)
        id = find_product(identifier: identifier)
        return if id.nil?

        connection.delete("products/#{id}")
      end

      def product_components(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/components")
        return response.body if response.success?

        []
      end

      def product_individuals(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/individuals")
        return response.body if response.success?

        []
      end

      def product_institutions(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/institutions")
        return response.body if response.success?

        []
      end

      #
      # Component
      #
      def components
        response = connection.get('components')
        return response.body if response.success?

        []
      end

      def find_component(identifier:)
        response = connection.get("component", identifier: identifier)
        return response.body["id"] if response.success?

        nil
      end

      def find_component_by_noid(noid:)
        response = connection.get("component", noid: noid)
        return response.body["id"] if response.success?

        nil
      end

      def find_noid_by_identifier(identifier:)
        response = connection.get("noids", identifier: identifier)
        return response.body if response.success?

        nil
      end

      def find_noid_by_doi(doi:)
        response = connection.get("noids", doi: doi)
        return response.body if response.success?

        nil
      end

      def find_noid_by_isbn(isbn:)
        response = connection.get("noids", isbn: isbn)
        return response.body if response.success?

        nil
      end

      def create_component(identifier:, name:, noid:)
        response = connection.post("components", { component: { identifier: identifier, name: name, noid: noid } }.to_json)
        return response.body["id"] if response.success?

        warn "Unable to create component #{identifier} - #{response.body}"
        nil
      end

      def delete_component(identifier:)
        id = find_component(identifier: identifier)
        return if id.nil?

        connection.delete("components/#{id}")
      end

      def component_products(identifier:)
        component_id = find_component(identifier: identifier)
        return [] if component_id.nil?

        response = connection.get("components/#{component_id}/products")
        return response.body if response.success?

        []
      end

      #
      # Product Component
      #
      def product_component?(product_identifier:, component_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_component(identifier: component_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.get("/api/products/#{product_id}/components/#{id}")
        response.success?
      end

      def add_product_component(product_identifier:, component_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_component(identifier: component_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.put("products/#{product_id}/components/#{id}")
        response.success?
      end

      def remove_product_component(product_identifier:, component_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_component(identifier: component_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.delete("products/#{product_id}/components/#{id}")
        response.success?
      end

      #
      # Individual
      #
      def individuals
        response = connection.get('individuals')
        return response.body if response.success?

        []
      end

      def find_individual(identifier:)
        response = connection.get("individual", identifier: identifier)
        return response.body["id"] if response.success?

        nil
      end

      def create_individual(identifier:, name:, email:)
        response = connection.post("individuals", { individual: { identifier: identifier, name: name, email: email } }.to_json)
        return response.body["id"] if response.success?

        warn "Unable to create individual #{identifier} - #{response.body}"
        nil
      end

      def delete_individual(identifier:)
        id = find_individual(identifier: identifier)
        return if id.nil?

        connection.delete("individuals/#{id}")
      end

      def individual_products(identifier:)
        individual_id = find_individual(identifier: identifier)
        return [] if individual_id.nil?

        response = connection.get("individuals/#{individual_id}/products")
        return response.body if response.success?

        []
      end

      #
      # Institution
      #
      def institutions
        response = connection.get('institutions')
        return response.body if response.success?

        []
      end

      def find_institution(identifier:)
        response = connection.get("institution", identifier: identifier)
        return response.body["id"] if response.success?

        nil
      end

      def create_institution(identifier:, name:, entity_id:)
        response = connection.post("institutions", { institution: { identifier: identifier, name: name, entity_id: entity_id } }.to_json)
        return response.body["id"] if response.success?

        warn "Unable to create institution #{identifier} - #{response.body}"
        nil
      end

      def delete_institution(identifier:)
        id = find_institution(identifier: identifier)
        return if id.nil?

        connection.delete("institutions/#{id}")
      end

      def institution_products(identifier:)
        institution_id = find_institution(identifier: identifier)
        return [] if institution_id.nil?

        response = connection.get("institutions/#{institution_id}/products")
        return response.body if response.success?

        []
      end

      #
      # Subscriptions
      #

      def product_individual_subscribed?(product_identifier:, individual_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_individual(identifier: individual_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.get("products/#{product_id}/individuals/#{id}")
        response.success?
      end

      def unsubscribe_product_individual(product_identifier:, individual_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_individual(identifier: individual_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.delete("products/#{product_id}/individuals/#{id}")
        response.success?
      end

      def product_institution_subscribed?(product_identifier:, institution_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_institution(identifier: institution_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.get("products/#{product_id}/institutions/#{id}")
        response.success?
      end

      def unsubscribe_product_institution(product_identifier:, institution_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_institution(identifier: institution_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.delete("products/#{product_id}/institutions/#{id}")
        response.success?
      end

      #
      # License { :full, :read, :none }
      #
      #   :full - both read and download access
      #   :read - read access (no download access)
      #   :none - expired access
      #
      #   :undefined - no association between subscriber and product
      #

      def product_individual_license?(product_identifier:, individual_identifier:, license:)
        return false unless LICENSES.include?(license)

        license == get_product_individual_license(product_identifier: product_identifier, individual_identifier: individual_identifier)
      end

      def get_product_individual_license(product_identifier:, individual_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_individual(identifier: individual_identifier)
        return :undefined if product_id.nil? || id.nil?

        response = connection.get("products/#{product_id}/individuals/#{id}/license")
        return :undefined unless response.success?

        response.body["license"].to_sym
      end

      def set_product_individual_license(product_identifier:, individual_identifier:, license:)
        return false unless LICENSES.include?(license)

        product_id = find_product(identifier: product_identifier)
        id = find_individual(identifier: individual_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.post("products/#{product_id}/individuals/#{id}/license", { license: license }.to_json)
        return true if response.success?

        warn "Failed to set license #{license} on product #{product_identifier} for individual #{individual_identifier}"
        false
      end

      def product_institution_license?(product_identifier:, institution_identifier:, license:)
        return false unless LICENSES.include?(license)

        license == get_product_institution_license(product_identifier: product_identifier, institution_identifier: institution_identifier)
      end

      def get_product_institution_license(product_identifier:, institution_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_institution(identifier: institution_identifier)
        return :undefined if product_id.nil? || id.nil?

        response = connection.get("products/#{product_id}/institutions/#{id}/license")
        return :undefined unless response.success?

        response.body["license"].to_sym
      end

      def set_product_institution_license(product_identifier:, institution_identifier:, license:)
        return false unless LICENSES.include?(license)

        product_id = find_product(identifier: product_identifier)
        id = find_institution(identifier: institution_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.post("products/#{product_id}/institutions/#{id}/license", { license: license }.to_json)
        return true if response.success?

        warn "Failed to set license #{license} on product #{product_identifier} for institution #{institution_identifier}"
        false
      end

      #
      # Configuration
      #
      def initialize(options = {})
        @base = options[:base] || ENV['TURNSOLE_HELIOTROPE_API']
        @token = options[:token] || ENV['TURNSOLE_HELIOTROPE_TOKEN']
      end

      private

        #
        # Connection
        #
        def connection
          @connection ||= Faraday.new(@base) do |conn|
            conn.headers = {
              authorization: "Bearer #{@token}",
              accept: "application/json, application/vnd.heliotrope.v1+json",
              content_type: "application/json"
            }
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.adapter Faraday.default_adapter
          end
        end
    end
  end
end
