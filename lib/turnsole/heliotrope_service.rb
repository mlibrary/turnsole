#!/usr/bin/env ruby
# frozen_string_literal: true

require 'httparty'

module Turnsole
  class HeliotropeService # rubocop:disable Metrics/ClassLength
    include HTTParty
    format :json
    base_uri ENV['HELIOTROPE_BASE_URI']
    headers authorization: "Bearer #{ENV['HELIOTROPE_TOKEN']}",
            accept: "application/json, application/vnd.heliotrope.v1+json",
            content_type: "application/json"

    def create_component(handle:)
      response = self.class.post("/components", body: { component: { identifier: handle, noid: Turnsole::Handle::Service.noid(handle) || handle, handle: handle } }.to_json)
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def find_or_create_component(handle:)
      id = find_component(handle: handle)
      return id unless id.nil?
      create_component(handle: handle)
    end

    def delete_component(handle:)
      id = find_component(handle: handle)
      return if id.nil?
      self.class.delete("/components/#{id}")
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def components
      self.class.get('/components').parsed_response
    end

    def find_component(handle:)
      response = self.class.get("/component", query: { identifier: handle })
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def create_product(identifier:, name:, purchase: "x")
      response = self.class.post("/products", body: { product: { identifier: identifier, name: name, purchase: purchase } }.to_json)
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def find_or_create_product(identifier:)
      id = find_product(identifier: identifier)
      return id unless id.nil?
      create_product(identifier: identifier, name: identifier, purchase: identifier)
    end

    def delete_product(identifier:)
      id = find_product(identifier: identifier)
      return if id.nil?
      self.class.delete("/products/#{id}")
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def products
      self.class.get('/products').parsed_response
    end

    def find_product(identifier:)
      response = self.class.get("/product", query: { identifier: identifier })
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def product_lessees(product_identifier:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      product_id = find_product(identifier: product_identifier)
      return [] if product_id.nil?
      # response = self.class.get("/products/#{product_id}/lessees")
      # return response.parsed_response if response.success?
      lessees = []
      individuals = self.class.get("/products/#{product_id}/individuals")
      lessees += individuals.parsed_response if individuals.success?
      institutions = self.class.get("/products/#{product_id}/institutions")
      lessees += institutions.parsed_response if institutions.success?
      lessees
    rescue StandardError => e
      STDERR.puts e.message
      []
    end

    def find_institution(identifier:)
      response = self.class.get("/institution", query: { identifier: identifier })
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def create_institution(identifier:, name:, entity_id:)
      response = self.class.post("/institutions", body: { institution: { identifier: identifier, name: name, entity_id: entity_id } }.to_json)
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def find_or_create_institution(identifier:, name:, entity_id:)
      id = find_institution(identifier: identifier)
      return id unless id.nil?
      create_institution(identifier: identifier, name: name, entity_id: entity_id)
    end

    def delete_institution(identifier:)
      id = find_institution(identifier: identifier)
      return if id.nil?
      self.class.delete("/institutions/#{id}")
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def institutions
      self.class.get('/institutions').parsed_response
    end

    def find_lessee(identifier:)
      # response = self.class.get("/lessee", { query: { identifier: identifier } } )
      response = self.class.get("/individual", query: { identifier: identifier })
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def create_lessee(identifier:)
      # response = self.class.post("/lessees", { body: { lessee: { identifier: identifier }  }.to_json } )
      response = self.class.post("/individuals", body: { individual: { identifier: identifier, name: identifier, email: identifier } }.to_json)
      return response.parsed_response["id"] if response.success?
      nil
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def find_or_create_lessee(identifier:)
      id = find_lessee(identifier: identifier)
      return id unless id.nil?
      create_lessee(identifier: identifier)
    end

    def delete_lessee(identifier:)
      id = find_lessee(identifier: identifier)
      return if id.nil?
      # self.class.delete("/lessees/#{id}")
      self.class.delete("/individuals/#{id}")
    rescue StandardError => e
      STDERR.puts e.message
      nil
    end

    def lessees
      # self.class.get('/lessees').parsed_response
      self.class.get('/individuals').parsed_response
    end

    def lessee_products(lessee_identifier:) # rubocop:disable Metrics/MethodLength
      institution_id = find_institution(identifier: lessee_identifier)
      if institution_id
        response = self.class.get("/institutions/#{institution_id}/products")
      else
        individual_id = find_lessee(identifier: lessee_identifier)
        return [] if individual_id.nil?
        # response = self.class.get("/lessees/#{lessee_id}/products")
        response = self.class.get("/individuals/#{individual_id}/products")
      end
      return response.parsed_response if response.success?
      []
    rescue StandardError => e
      STDERR.puts e.message
      []
    end

    def component_products(handle:)
      component_id = find_component(handle: handle)
      return [] if component_id.nil?
      response = self.class.get("/components/#{component_id}/products")
      return response.parsed_response if response.success?
      []
    rescue StandardError => e
      STDERR.puts e.message
      []
    end

    def product_components(product_identifier:)
      product_id = find_product(identifier: product_identifier)
      return [] if product_id.nil?
      response = self.class.get("/products/#{product_id}/components")
      return response.parsed_response if response.success?
      []
    rescue StandardError => e
      STDERR.puts e.message
      []
    end

    def link(product_identifier:, lessee_identifier:)
      product_id = find_or_create_product(identifier: product_identifier)
      institution_id = find_institution(identifier: lessee_identifier)
      if institution_id
        link_product_institution(product_id: product_id, institution_id: institution_id)
      else
        individual_id = find_or_create_lessee(identifier: lessee_identifier)
        link_product_individual(product_id: product_id, individual_id: individual_id)
      end
    end

    def unlink(product_identifier:, lessee_identifier:)
      product_id = find_or_create_product(identifier: product_identifier)
      institution_id = find_institution(identifier: lessee_identifier)
      if institution_id
        unlink_product_institution(product_id: product_id, institution_id: institution_id)
      else
        individual_id = find_or_create_lessee(identifier: lessee_identifier)
        unlink_product_individual(product_id: product_id, individual_id: individual_id)
      end
    end

    def link_component(product_identifier:, handle:)
      product_id = find_or_create_product(identifier: product_identifier)
      component_id = find_or_create_component(handle: handle)
      link_product_component(product_id: product_id, component_id: component_id)
    end

    def unlink_component(product_identifier:, handle:)
      product_id = find_or_create_product(identifier: product_identifier)
      component_id = find_or_create_component(handle: handle)
      unlink_product_component(product_id: product_id, component_id: component_id)
    end

    private

      def link_product_individual(product_id:, individual_id:)
        response = self.class.put("/products/#{product_id}/individuals/#{individual_id}")
        response.success?
      rescue StandardError => e
        STDERR.puts e.message
        false
      end

      def unlink_product_individual(product_id:, individual_id:)
        response = self.class.delete("/products/#{product_id}/individuals/#{individual_id}")
        response.success?
      rescue StandardError => e
        STDERR.puts e.message
        false
      end

      def link_product_institution(product_id:, institution_id:)
        response = self.class.put("/products/#{product_id}/institutions/#{institution_id}")
        response.success?
      rescue StandardError => e
        STDERR.puts e.message
        false
      end

      def unlink_product_institution(product_id:, institution_id:)
        response = self.class.delete("/products/#{product_id}/institutions/#{institution_id}")
        response.success?
      rescue StandardError => e
        STDERR.puts e.message
        false
      end

      def link_product_component(product_id:, component_id:)
        response = self.class.put("/products/#{product_id}/components/#{component_id}")
        response.success?
      rescue StandardError => e
        STDERR.puts e.message
        false
      end

      def unlink_product_component(product_id:, component_id:)
        response = self.class.delete("/products/#{product_id}/components/#{component_id}")
        response.success?
      rescue StandardError => e
        STDERR.puts e.message
        false
      end
  end
end
