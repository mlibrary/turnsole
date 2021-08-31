# frozen_string_literal: true

RSpec.describe Turnsole::Heliotrope::Service do
  service = described_class.new

  #
  # Cannot create components because noid has to be valid!!!
  #

  products_initial_count = service.products.count
  # components_initial_count = service.components.count
  individuals_initial_count = service.individuals.count
  institutions_initial_count = service.institutions.count

  n = 3
  products = []
  # components = []
  individuals = []
  institutions = []

  before do
    n.times do |i|
      products << "test_product_#{i}"
      service.create_product(identifier: products[i], name: "Test Product #{i}")
      # components << "component#{i}"
      # service.create_component(identifier: components[i], name: "component#{i}", noid: "component#{i}")
      individuals << "test_individual_#{i}"
      service.create_individual(identifier: individuals[i], name: "Test Individual #{i}", email: "test_individual_#{i}@test.com")
      inst = {}
      inst['inst_id'] = (10_000 + (i * 10)).to_s
      inst['inst_name'] = "Test Institution #{i}"
      inst['entity_id'] = "entity_id_#{i}" if i.odd? # test that field is optional
      institutions << inst
      if inst['entity_id']
        service.create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: inst['entity_id'])
      else
        service.create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: '')
      end
      service.create_institution_affiliation(identifier: inst['inst_id'], dlps_institution_id: inst['inst_id'].to_i, affiliation: :member)
      service.create_institution_affiliation(identifier: inst['inst_id'], dlps_institution_id: inst['inst_id'].to_i + 1, affiliation: :alum)
    end
    products_initial_count = service.products.count - n
    # components_initial_count = service.components.count - n
    individuals_initial_count = service.individuals.count - n
    institutions_initial_count = service.institutions.count - n
  end

  after do
    n.times do |i|
      n.times do |j|
        service.delete_product_individual_license(identifier: products[i], individual_identifier: individuals[j])
        service.delete_product_institution_license(identifier: products[i], institution_identifier: institutions[j]['inst_id'])
        service.delete_product_institution_license(identifier: products[i], institution_identifier: institutions[j]['inst_id'], affiliation: :alum)
        # service.remove_product_component(product_identifier: products[i], component_identifier: components[j])
      end
    end
    n.times do |i|
      service.delete_product(identifier: products[i])
      # service.delete_component(identifier: components[i])
      service.delete_individual(identifier: individuals[i])
      service.delete_institution_affiliation(identifier: institutions[i]['inst_id'], dlps_institution_id: institutions[i]['inst_id'].to_i, affiliation: :member)
      service.delete_institution_affiliation(identifier: institutions[i]['inst_id'], dlps_institution_id: institutions[i]['inst_id'].to_i + 1, affiliation: :alum)
      service.delete_institution(identifier: institutions[i]['inst_id'])
    end
  end

  it 'works' do
    expect(service.products.count).to eq(products_initial_count + n)
    # expect(service.components.count).to eq(components_initial_count + n)
    expect(service.individuals.count).to eq(individuals_initial_count + n)
    expect(service.institutions.count).to eq(institutions_initial_count + n)

    n.times do |i|
      expect(service.product_components(identifier: products[i]).count).to eq 0
      # expect(service.component_products(identifier: components[i]).count).to eq 0
      expect(service.product_individuals(identifier: products[i]).count).to eq 0
      expect(service.individual_products(identifier: individuals[i]).count).to eq 0
      expect(service.product_institutions(identifier: products[i]).count).to eq 0
      expect(service.institution_products(identifier: institutions[i]['inst_id']).count).to eq 0
      expect(service.product_licenses(identifier: products[i]).count).to eq 0
      expect(service.individual_licenses(identifier: individuals[i]).count).to eq 0
      expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq 0
      expect(service.institution_affiliations(identifier: institutions[i]['inst_id']).count).to eq 2
    end

    n.times do |i|
      service.delete_product_individual_license(identifier: products[0], individual_identifier: individuals[i])
      service.delete_product_individual_license(identifier: products[i], individual_identifier: individuals[0])
      service.delete_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])
      service.delete_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])
    end

    # Create "unknown" licenses is a no operation (nop)"
    n.times do |i|
      expect(service.create_product_individual_license(identifier: products[0], individual_identifier: individuals[i], license_type: :unknown)).to be false
      expect(service.create_product_individual_license(identifier: products[i], individual_identifier: individuals[0], license_type: :unknown)).to be false
      expect(service.create_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], license_type: :unknown)).to be false
      expect(service.create_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], license_type: :unknown)).to be false
    end

    # Can't find licenses
    n.times do |i|
      expect(service.find_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be nil
      expect(service.find_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be nil
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be nil
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be nil
      expect(service.product_licenses(identifier: products[i]).count).to eq 0
      expect(service.individual_licenses(identifier: individuals[i]).count).to eq 0
      expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq 0
    end

    # Create "full" licenses (default)
    n.times do |i|
      expect(service.create_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be true
      expect(service.create_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be true
      expect(service.create_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be true
      expect(service.create_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be true
    end

    # One license for each individual and institution
    n.times do |i|
      if i == 0
        expect(service.product_licenses(identifier: products[i]).count).to eq(2 * n)
        expect(service.individual_licenses(identifier: individuals[i]).count).to eq n
        expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq n
      else
        expect(service.product_licenses(identifier: products[i]).count).to eq 2
        expect(service.individual_licenses(identifier: individuals[i]).count).to eq 1
        expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq 1
      end
    end

    # Find "full" licenses
    n.times do |i|
      expect(service.find_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be :full
      expect(service.find_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be :full
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be :full
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be :full
    end

    # Create "read" licenses
    n.times do |i|
      expect(service.create_product_individual_license(identifier: products[0], individual_identifier: individuals[i], license_type: :read)).to be true
      expect(service.create_product_individual_license(identifier: products[i], individual_identifier: individuals[0], license_type: :read)).to be true
      expect(service.create_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], license_type: :read)).to be true
      expect(service.create_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], license_type: :read)).to be true
    end

    # Find "read" licenses
    n.times do |i|
      expect(service.find_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be :read
      expect(service.find_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be :read
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be :read
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be :read
    end

    # Create "unknown" licenses is a no operation (nop)"
    n.times do |i|
      expect(service.create_product_individual_license(identifier: products[0], individual_identifier: individuals[i], license_type: :unknown)).to be false
      expect(service.create_product_individual_license(identifier: products[i], individual_identifier: individuals[0], license_type: :unknown)).to be false
      expect(service.create_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], license_type: :unknown)).to be false
      expect(service.create_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], license_type: :unknown)).to be false
    end

    # Find "read" licenses
    n.times do |i|
      expect(service.find_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be :read
      expect(service.find_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be :read
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be :read
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be :read
    end

    # Can't find alum licenses
    n.times do |i|
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum)).to be nil
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum)).to be nil
    end

    # Create alum "full" licenses (default)
    n.times do |i|
      expect(service.create_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum)).to be true
      expect(service.create_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum)).to be true
    end

    # One license for each individual and two licenses for each institution
    n.times do |i|
      if i == 0
        expect(service.product_licenses(identifier: products[i]).count).to eq(3 * n)
        expect(service.individual_licenses(identifier: individuals[i]).count).to eq n
        expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq(2 * n)
      else
        expect(service.product_licenses(identifier: products[i]).count).to eq 3
        expect(service.individual_licenses(identifier: individuals[i]).count).to eq 1
        expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq 2
      end
    end

    # Find alum "Full" licenses
    n.times do |i|
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum)).to be :full
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum)).to be :full
    end

    # Create alum "read" licenses
    n.times do |i|
      expect(service.create_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum, license_type: :read)).to be true
      expect(service.create_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum, license_type: :read)).to be true
    end

    # One license for each individual and institution
    n.times do |i|
      if i == 0
        expect(service.product_licenses(identifier: products[i]).count).to eq(2 * n)
        expect(service.individual_licenses(identifier: individuals[i]).count).to eq n
        expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq n
      else
        expect(service.product_licenses(identifier: products[i]).count).to eq 2
        expect(service.individual_licenses(identifier: individuals[i]).count).to eq 1
        expect(service.institution_licenses(identifier: institutions[i]['inst_id']).count).to eq 1
      end
    end

    # Find alum "Read" licenses
    n.times do |i|
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum)).to be :read
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum)).to be :read
    end

    # Delete licenses
    n.times do |i|
      service.delete_product_individual_license(identifier: products[0], individual_identifier: individuals[i])
      service.delete_product_individual_license(identifier: products[i], individual_identifier: individuals[0])
      service.delete_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])
      service.delete_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum)
      service.delete_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])
      service.delete_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum)
    end

    # Can't find licenses
    n.times do |i|
      expect(service.find_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be nil
      expect(service.find_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be nil
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be nil
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'], affiliation: :alum)).to be nil
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be nil
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'], affiliation: :alum)).to be nil
    end

    expect(service.product_individuals(identifier: products[0]).count).to eq 0
    expect(service.individual_products(identifier: individuals[0]).count).to eq 0
    expect(service.product_institutions(identifier: products[0]).count).to eq 0
    expect(service.institution_products(identifier: institutions[0]['inst_id']).count).to eq 0

    n.times do |i|
      expect(service.find_product_individual_license(identifier: products[0], individual_identifier: individuals[i])).to be nil
      expect(service.find_product_individual_license(identifier: products[i], individual_identifier: individuals[0])).to be nil
      expect(service.find_product_institution_license(identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be nil
      expect(service.find_product_institution_license(identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be nil
    end
  end
end
