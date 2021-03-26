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

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    n.times do |i|
      products << "product#{i}"
      service.create_product(identifier: products[i], name: "product#{i}", purchase: "product#{i}")
      # components << "component#{i}"
      # service.create_component(identifier: components[i], name: "component#{i}", noid: "component#{i}")
      individuals << "individual#{i}"
      service.create_individual(identifier: individuals[i], name: "individual#{i}", email: "individual#{i}")
      inst = {}
      inst['inst_id'] = "instid_#{i}"
      inst['inst_name'] = "Institution #{i}"
      inst['entity_id'] = "entity_id_#{i}" if i.odd? # test that field is optional
      institutions << inst
      if inst['entity_id']
        service.create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: inst['entity_id'])
      else
        service.create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: '')
      end
    end
    products_initial_count = service.products.count - n
    # components_initial_count = service.components.count - n
    individuals_initial_count = service.individuals.count - n
    institutions_initial_count = service.institutions.count - n
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    n.times do |i|
      n.times do |j|
        service.unsubscribe_product_individual(product_identifier: products[i], individual_identifier: individuals[j])
        service.unsubscribe_product_institution(product_identifier: products[i], institution_identifier: institutions[j]['inst_id'])
        # service.remove_product_component(product_identifier: products[i], component_identifier: components[j])
      end
    end
    n.times do |i|
      service.delete_product(identifier: products[i])
      # service.delete_component(identifier: components[i])
      service.delete_individual(identifier: individuals[i])
      service.delete_institution(identifier: institutions[i]['inst_id'])
    end
  end

  it 'works' do
    expect(service.products.count).to eq(products_initial_count + n)
    # expect(service.components.count).to eq(components_initial_count + n)
    expect(service.individuals.count).to eq(individuals_initial_count + n)
    expect(service.institutions.count).to eq(institutions_initial_count + n)

    n.times do |i|
      expect(service.product_components(identifier: products[i]).count).to eq(0)
      # expect(service.component_products(identifier: components[i]).count).to eq(0)
      expect(service.product_individuals(identifier: products[i]).count).to eq(0)
      expect(service.individual_products(identifier: individuals[i]).count).to eq(0)
      expect(service.product_institutions(identifier: products[i]).count).to eq(0)
      expect(service.institution_products(identifier: institutions[i]['inst_id']).count).to eq(0)
    end

    n.times do |i|
      service.unsubscribe_product_individual(product_identifier: products[0], individual_identifier: individuals[i])
      service.unsubscribe_product_individual(product_identifier: products[i], individual_identifier: individuals[0])
      service.unsubscribe_product_institution(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'])
      service.unsubscribe_product_institution(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'])
    end

    # Can't create "undefined" licenses
    n.times do |i|
      expect(service.set_product_individual_license(product_identifier: products[0], individual_identifier: individuals[i], license: :undefined)).to be false
      expect(service.set_product_individual_license(product_identifier: products[i], individual_identifier: individuals[0], license: :undefined)).to be false
      expect(service.set_product_institution_license(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :undefined)).to be false
      expect(service.set_product_institution_license(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :undefined)).to be false
    end

    # Create "full" licenses
    n.times do |i|
      expect(service.set_product_individual_license(product_identifier: products[0], individual_identifier: individuals[i], license: :full)).to be true
      expect(service.set_product_individual_license(product_identifier: products[i], individual_identifier: individuals[0], license: :full)).to be true
      expect(service.set_product_institution_license(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :full)).to be true
      expect(service.set_product_institution_license(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :full)).to be true
    end

    n.times do |i|
      expect(service.product_individual_license?(product_identifier: products[0], individual_identifier: individuals[i], license: :full)).to be true
      expect(service.product_individual_license?(product_identifier: products[i], individual_identifier: individuals[0], license: :full)).to be true
      expect(service.product_institution_license?(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :full)).to be true
      expect(service.product_institution_license?(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :full)).to be true
    end

    # Set licenses to "read"
    n.times do |i|
      expect(service.set_product_individual_license(product_identifier: products[0], individual_identifier: individuals[i], license: :read)).to be true
      expect(service.set_product_individual_license(product_identifier: products[i], individual_identifier: individuals[0], license: :read)).to be true
      expect(service.set_product_institution_license(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :read)).to be true
      expect(service.set_product_institution_license(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :read)).to be true
    end

    n.times do |i|
      expect(service.product_individual_license?(product_identifier: products[0], individual_identifier: individuals[i], license: :full)).to be false
      expect(service.product_individual_license?(product_identifier: products[i], individual_identifier: individuals[0], license: :full)).to be false
      expect(service.product_institution_license?(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :full)).to be false
      expect(service.product_institution_license?(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :full)).to be false
    end

    n.times do |i|
      expect(service.product_individual_license?(product_identifier: products[0], individual_identifier: individuals[i], license: :read)).to be true
      expect(service.product_individual_license?(product_identifier: products[i], individual_identifier: individuals[0], license: :read)).to be true
      expect(service.product_institution_license?(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :read)).to be true
      expect(service.product_institution_license?(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :read)).to be true
    end

    # Set licenses to "none"
    n.times do |i|
      expect(service.set_product_individual_license(product_identifier: products[0], individual_identifier: individuals[i], license: :none)).to be true
      expect(service.set_product_individual_license(product_identifier: products[i], individual_identifier: individuals[0], license: :none)).to be true
      expect(service.set_product_institution_license(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :none)).to be true
      expect(service.set_product_institution_license(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :none)).to be true
    end

    n.times do |i|
      expect(service.product_individual_license?(product_identifier: products[0], individual_identifier: individuals[i], license: :read)).to be false
      expect(service.product_individual_license?(product_identifier: products[i], individual_identifier: individuals[0], license: :read)).to be false
      expect(service.product_institution_license?(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :read)).to be false
      expect(service.product_institution_license?(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :read)).to be false
    end

    n.times do |i|
      expect(service.product_individual_license?(product_identifier: products[0], individual_identifier: individuals[i], license: :none)).to be true
      expect(service.product_individual_license?(product_identifier: products[i], individual_identifier: individuals[0], license: :none)).to be true
      expect(service.product_institution_license?(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :none)).to be true
      expect(service.product_institution_license?(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :none)).to be true
    end

    # Delete everything.
    n.times do |i|
      service.unsubscribe_product_individual(product_identifier: products[0], individual_identifier: individuals[i])
      service.unsubscribe_product_individual(product_identifier: products[i], individual_identifier: individuals[0])
      service.unsubscribe_product_institution(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'])
      service.unsubscribe_product_institution(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'])
    end
    expect(service.product_individuals(identifier: products[0]).count).to eq(0)
    expect(service.individual_products(identifier: individuals[0]).count).to eq(0)
    expect(service.product_institutions(identifier: products[0]).count).to eq(0)
    expect(service.institution_products(identifier: institutions[0]['inst_id']).count).to eq(0)

    n.times do |i|
      expect(service.product_individual_license?(product_identifier: products[0], individual_identifier: individuals[i], license: :none)).to be false
      expect(service.product_individual_license?(product_identifier: products[i], individual_identifier: individuals[0], license: :none)).to be false
      expect(service.product_institution_license?(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'], license: :none)).to be false
      expect(service.product_institution_license?(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'], license: :none)).to be false
    end

    n.times do |i|
      expect(service.get_product_individual_license(product_identifier: products[0], individual_identifier: individuals[i])).to be :undefined
      expect(service.get_product_individual_license(product_identifier: products[i], individual_identifier: individuals[0])).to be :undefined
      expect(service.get_product_institution_license(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'])).to be :undefined
      expect(service.get_product_institution_license(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'])).to be :undefined
    end
  end
  #These rely on this Monograph on preview: https://heliotrope-preview.hydra.lib.umich.edu/concern/monographs/kw52j9144?locale=en
  it "finds a NOID by identifier" do
    expect(service.find_noid_by_identifier(identifier: 'ahab90909')[0]['id']).to eq('kw52j9144')
  end
  it "finds a NOID by DOI" do
    expect(service.find_noid_by_doi(doi: '10.3998/mpub.192640')[0]['id']).to eq('kw52j9144')
  end
  it "finds a NOID by DOI URL" do
    expect(service.find_noid_by_doi(doi: 'https://doi.org/10.3998/mpub.192640')[0]['id']).to eq('kw52j9144')
  end
  it "finds a NOID by ISBN (with dashes)" do
    expect(service.find_noid_by_isbn(isbn: '978-0-472-05122-9')[0]['id']).to eq('kw52j9144')
  end
  it "finds a NOID by ISBN (without dashes)" do
    expect(service.find_noid_by_isbn(isbn: '9780472051229')[0]['id']).to eq('kw52j9144')
  end
end
