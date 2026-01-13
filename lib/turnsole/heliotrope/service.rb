# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'json'

module Turnsole
  module Heliotrope
    class Service # rubocop:disable Metrics/ClassLength
      class ApiError < StandardError; end

      #
      # Product
      #
      def products
        response = connection.get('products')
        return response.body if response.success?

        raise ApiError, "Failed to fetch products: HTTP #{response.status} - #{response.body}"
      end

      def find_product(identifier:)
        response = connection.get("product", identifier: identifier)
        return response.body["id"] if response.success?

        raise ApiError, "Failed to find product '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def create_product(identifier:, name:, purchase: "x")
        response = connection.post("products", { product: { identifier: identifier, name: name, purchase: purchase } }.to_json)
        return response.body["id"] if response.success?

        raise ApiError, "Unable to create product '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def delete_product(identifier:)
        id = find_product(identifier: identifier)
        return if id.nil?

        response = connection.delete("products/#{id}")
        raise ApiError, "Failed to delete product '#{identifier}': HTTP #{response.status} - #{response.body}" unless response.success?
      end

      def product_components(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/components")
        return response.body if response.success?

        raise ApiError, "Failed to fetch product components for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def product_individuals(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/individuals")
        return response.body if response.success?

        raise ApiError, "Failed to fetch product individuals for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def product_institutions(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/institutions")
        return response.body if response.success?

        raise ApiError, "Failed to fetch product institutions for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def product_licenses(identifier:)
        product_id = find_product(identifier: identifier)
        return [] if product_id.nil?

        response = connection.get("products/#{product_id}/licenses")
        return response.body if response.success?

        raise ApiError, "Failed to fetch product licenses for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def find_product_individual_license(identifier:, individual_identifier:)
        product_id = find_product(identifier: identifier)
        return false if product_id.nil?

        individual_id = find_individual(identifier: individual_identifier)
        return false if individual_id.nil?

        response = connection.get("products/#{product_id}/individuals/#{individual_id}/license")
        if response.success?
          return Heliotrope.decode_license_type(response.body["type"])
        end

        return nil if response.status == 404

        raise ApiError, "Failed to find product individual license for product '#{identifier}', individual '#{individual_identifier}': HTTP #{response.status} - #{response.body}"
      end

      def create_product_individual_license(identifier:, individual_identifier:, license_type: :full)
        product_id = find_product(identifier: identifier)
        return false if product_id.nil?

        individual_id = find_individual(identifier: individual_identifier)
        return false if individual_id.nil?

        type = Heliotrope.encode_license_type(license_type)
        return false if type.nil?

        response = connection.post("products/#{product_id}/individuals/#{individual_id}/license", { license: { type: type } }.to_json)
        return true if response.success?

        raise ApiError, "Unable to create product '#{identifier}' individual '#{individual_identifier}' license '#{license_type}': HTTP #{response.status} - #{response.body}"
      end

      def delete_product_individual_license(identifier:, individual_identifier:)
        product_id = find_product(identifier: identifier)
        return false if product_id.nil?

        individual_id = find_individual(identifier: individual_identifier)
        return false if individual_id.nil?

        response = connection.delete("products/#{product_id}/individuals/#{individual_id}/license")
        return true if response.success?
        return true if response.status == 404  # Already deleted or never existed

        raise ApiError, "Unable to delete product '#{identifier}' individual '#{individual_identifier}' license: HTTP #{response.status} - #{response.body}"
      end

      def find_product_institution_license(identifier:, institution_identifier:, affiliation: :member)
        product_id = find_product(identifier: identifier)
        return false if product_id.nil?

        institution_id = find_institution(identifier: institution_identifier)
        return false if institution_id.nil?

        response = connection.get("products/#{product_id}/institutions/#{institution_id}/license/#{affiliation}")
        if response.success?
          return Heliotrope.decode_license_type(response.body["type"])
        end

        return nil if response.status == 404

        raise ApiError, "Failed to find product institution license for product '#{identifier}', institution '#{institution_identifier}', affiliation '#{affiliation}': HTTP #{response.status} - #{response.body}"
      end

      def create_product_institution_license(identifier:, institution_identifier:, affiliation: :member, license_type: :full)
        product_id = find_product(identifier: identifier)
        return false if product_id.nil?

        institution_id = find_institution(identifier: institution_identifier)
        return false if institution_id.nil?

        type = Heliotrope.encode_license_type(license_type)
        return false if type.nil?

        response = connection.post("products/#{product_id}/institutions/#{institution_id}/license/#{affiliation}", { license: { type: type } }.to_json)
        return true if response.success?

        raise ApiError, "Unable to create product '#{identifier}' institution '#{institution_identifier}' license '#{license_type}' affiliation '#{affiliation}': HTTP #{response.status} - #{response.body}"
      end

      def delete_product_institution_license(identifier:, institution_identifier:, affiliation: :member)
        product_id = find_product(identifier: identifier)
        return false if product_id.nil?

        institution_id = find_institution(identifier: institution_identifier)
        return false if institution_id.nil?

        response = connection.delete("products/#{product_id}/institutions/#{institution_id}/license/#{affiliation}")
        return true if response.success?
        return true if response.status == 404  # Already deleted or never existed

        raise ApiError, "Unable to delete product '#{identifier}' institution '#{institution_identifier}' license affiliation '#{affiliation}': HTTP #{response.status} - #{response.body}"
      end

      #
      # Component
      #
      def components
        response = connection.get('components')
        return response.body if response.success?

        raise ApiError, "Failed to fetch components: HTTP #{response.status} - #{response.body}"
      end

      def find_component(identifier:)
        response = connection.get("component", identifier: identifier)
        return response.body["id"] if response.success?

        raise ApiError, "Failed to find component '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def find_component_by_noid(noid:)
        response = connection.get("component", noid: noid)
        return response.body["id"] if response.success?

        raise ApiError, "Failed to find component by noid '#{noid}': HTTP #{response.status} - #{response.body}"
      end

      def find_noid_by_identifier(identifier:)
        response = connection.get("noids", identifier: identifier)
        return response.body if response.success?

        raise ApiError, "Failed to find noid by identifier '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def find_noid_by_doi(doi:)
        response = connection.get("noids", doi: doi)
        return response.body if response.success?

        raise ApiError, "Failed to find noid by doi '#{doi}': HTTP #{response.status} - #{response.body}"
      end

      def find_noid_by_isbn(isbn:)
        response = connection.get("noids", isbn: isbn)
        return response.body if response.success?

        raise ApiError, "Failed to find noid by isbn '#{isbn}': HTTP #{response.status} - #{response.body}"
      end

      def create_component(identifier:, name:, noid:)
        response = connection.post("components", { component: { identifier: identifier, name: name, noid: noid } }.to_json)
        return response.body["id"] if response.success?

        raise ApiError, "Unable to create component '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def delete_component(identifier:)
        id = find_component(identifier: identifier)
        return if id.nil?

        response = connection.delete("components/#{id}")
        raise ApiError, "Failed to delete component '#{identifier}': HTTP #{response.status} - #{response.body}" unless response.success?
      end

      def component_products(identifier:)
        component_id = find_component(identifier: identifier)
        return [] if component_id.nil?

        response = connection.get("components/#{component_id}/products")
        return response.body if response.success?

        raise ApiError, "Failed to fetch component products for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      #
      # Product Component
      #
      def product_component?(product_identifier:, component_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_component(identifier: component_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.get("/api/products/#{product_id}/components/#{id}")
        return response.success? if response.success? || response.status == 404

        raise ApiError, "Failed to check product component for product '#{product_identifier}', component '#{component_identifier}': HTTP #{response.status} - #{response.body}"
      end

      def add_product_component(product_identifier:, component_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_component(identifier: component_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.put("products/#{product_id}/components/#{id}")
        return true if response.success?

        raise ApiError, "Failed to add product component for product '#{product_identifier}', component '#{component_identifier}': HTTP #{response.status} - #{response.body}"
      end

      def remove_product_component(product_identifier:, component_identifier:)
        product_id = find_product(identifier: product_identifier)
        id = find_component(identifier: component_identifier)
        return false if product_id.nil? || id.nil?

        response = connection.delete("products/#{product_id}/components/#{id}")
        return true if response.success?

        raise ApiError, "Failed to remove product component for product '#{product_identifier}', component '#{component_identifier}': HTTP #{response.status} - #{response.body}"
      end

      #
      # Individual
      #
      def individuals
        response = connection.get('individuals')
        return response.body if response.success?

        raise ApiError, "Failed to fetch individuals: HTTP #{response.status} - #{response.body}"
      end

      def find_individual(identifier:)
        response = connection.get("individual", identifier: identifier)
        return response.body["id"] if response.success?

        raise ApiError, "Failed to find individual '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def create_individual(identifier:, name:, email:)
        response = connection.post("individuals", { individual: { identifier: identifier, name: name, email: email } }.to_json)
        return response.body["id"] if response.success?

        raise ApiError, "Unable to create individual '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def delete_individual(identifier:)
        id = find_individual(identifier: identifier)
        return if id.nil?

        response = connection.delete("individuals/#{id}")
        raise ApiError, "Failed to delete individual '#{identifier}': HTTP #{response.status} - #{response.body}" unless response.success?
      end

      def individual_products(identifier:)
        individual_id = find_individual(identifier: identifier)
        return [] if individual_id.nil?

        response = connection.get("individuals/#{individual_id}/products")
        return response.body if response.success?

        raise ApiError, "Failed to fetch individual products for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def individual_licenses(identifier:)
        individual_id = find_individual(identifier: identifier)
        return [] if individual_id.nil?

        response = connection.get("individuals/#{individual_id}/licenses")
        return response.body if response.success?

        raise ApiError, "Failed to fetch individual licenses for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      #
      # Institution
      #
      def institutions
        response = connection.get('institutions')
        return response.body if response.success?

        raise ApiError, "Failed to fetch institutions: HTTP #{response.status} - #{response.body}"
      end

      def find_institution(identifier:)
        response = connection.get("institution", identifier: identifier)
        return response.body["id"] if response.success?

        raise ApiError, "Failed to find institution '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def create_institution(identifier:, name:, entity_id:)
        response = connection.post("institutions", { institution: { identifier: identifier, name: name, entity_id: entity_id } }.to_json)
        return response.body["id"] if response.success?

        raise ApiError, "Unable to create institution '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def delete_institution(identifier:)
        id = find_institution(identifier: identifier)
        return if id.nil?

        response = connection.delete("institutions/#{id}")
        raise ApiError, "Failed to delete institution '#{identifier}': HTTP #{response.status} - #{response.body}" unless response.success?
      end

      def institution_affiliations(identifier:)
        institution_id = find_institution(identifier: identifier)
        return [] if institution_id.nil?

        response = connection.get("institutions/#{institution_id}/affiliations")
        return response.body if response.success?

        raise ApiError, "Failed to fetch institution affiliations for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def find_institution_affiliation(identifier:, dlps_institution_id:, affiliation:)
        institution_id = find_institution(identifier: identifier)
        return nil if institution_id.nil?

        response = connection.get("institutions/#{institution_id}/affiliation", dlps_institution_id: dlps_institution_id, affiliation: affiliation)
        return response.body["id"] if response.success?

        raise ApiError, "Failed to find institution affiliation for '#{identifier}', dlps_institution_id '#{dlps_institution_id}', affiliation '#{affiliation}': HTTP #{response.status} - #{response.body}"
      end

      def create_institution_affiliation(identifier:, dlps_institution_id:, affiliation:)
        institution_id = find_institution(identifier: identifier)
        return nil if institution_id.nil?

        response = connection.post("institutions/#{institution_id}/affiliations", { institution_affiliation: { institution_id: institution_id, dlps_institution_id: dlps_institution_id, affiliation: affiliation } }.to_json)
        return response.body["id"] if response.success?

        raise ApiError, "Unable to create institution affiliation for '#{identifier}', dlps_institution_id '#{dlps_institution_id}', affiliation '#{affiliation}': HTTP #{response.status} - #{response.body}"
      end

      def delete_institution_affiliation(identifier:, dlps_institution_id:, affiliation:)
        institution_id = find_institution(identifier: identifier)
        return nil if institution_id.nil?

        institution_affiliation_id = find_institution_affiliation(identifier: identifier, dlps_institution_id: dlps_institution_id, affiliation: affiliation)
        return nil if institution_affiliation_id.nil?

        response = connection.delete("institutions/#{institution_id}/affiliations/#{institution_affiliation_id}")
        raise ApiError, "Failed to delete institution affiliation for '#{identifier}', dlps_institution_id '#{dlps_institution_id}', affiliation '#{affiliation}': HTTP #{response.status} - #{response.body}" unless response.success?
      end

      def institution_products(identifier:)
        institution_id = find_institution(identifier: identifier)
        return [] if institution_id.nil?

        response = connection.get("institutions/#{institution_id}/products")
        return response.body if response.success?

        raise ApiError, "Failed to fetch institution products for '#{identifier}': HTTP #{response.status} - #{response.body}"
      end

      def institution_licenses(identifier:)
        institution_id = find_institution(identifier: identifier)
        return [] if institution_id.nil?

        response = connection.get("institutions/#{institution_id}/licenses")
        return response.body if response.success?

        raise ApiError, "Failed to fetch institution licenses for '#{identifier}': HTTP #{response.status} - #{response.body}"
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
