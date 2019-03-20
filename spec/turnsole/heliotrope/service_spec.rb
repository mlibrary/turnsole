# frozen_string_literal: true

RSpec.describe Turnsole::Heliotrope::Service do
  service = described_class.new

  products_initial_count = service.products.count
  components_initial_count = service.components.count
  individuals_initial_count = service.individuals.count
  institutions_initial_count = service.institutions.count

  n = 3
  products = []
  components = []
  individuals = []
  institutions = []

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    n.times do |i|
      products << "product#{i}"
      service.create_product(identifier: products[i], name: "product#{i}", purchase: "product#{i}")
      components << "component#{i}"
      service.create_component(identifier: components[i], name: "component#{i}", noid: "component#{i}")
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
    components_initial_count = service.components.count - n
    individuals_initial_count = service.individuals.count - n
    institutions_initial_count = service.institutions.count - n
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    n.times do |i|
      n.times do |j|
        service.unsubscribe_product_individual(product_identifier: products[i], individual_identifier: individuals[j])
        service.unsubscribe_product_institution(product_identifier: products[i], institution_identifier: institutions[j]['inst_id'])
        service.remove_product_component(product_identifier: products[i], component_identifier: components[j])
      end
    end
    n.times do |i|
      service.delete_product(identifier: products[i])
      service.delete_component(identifier: components[i])
      service.delete_individual(identifier: individuals[i])
      service.delete_institution(identifier: institutions[i]['inst_id'])
    end
  end

  it 'works' do
    expect(service.products.count).to eq(products_initial_count + n)
    expect(service.components.count).to eq(components_initial_count + n)
    expect(service.individuals.count).to eq(individuals_initial_count + n)
    expect(service.institutions.count).to eq(institutions_initial_count + n)

    n.times do |i|
      expect(service.product_components(identifier: products[i]).count).to eq(0)
      expect(service.component_products(identifier: components[i]).count).to eq(0)
      expect(service.product_individuals(identifier: products[i]).count).to eq(0)
      expect(service.individual_products(identifier: individuals[i]).count).to eq(0)
      expect(service.product_institutions(identifier: products[i]).count).to eq(0)
      expect(service.institution_products(identifier: institutions[i]['inst_id']).count).to eq(0)
    end

    n.times do |i|
      service.subscribe_product_individual(product_identifier: products[0], individual_identifier: individuals[i])
    end
    expect(service.product_individuals(identifier: products[0]).count).to eq(n)

    n.times do |i|
      service.subscribe_product_institution(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'])
    end
    expect(service.product_institutions(identifier: products[0]).count).to eq(n)

    n.times do |i|
      service.subscribe_product_individual(product_identifier: products[i], individual_identifier: individuals[0])
    end
    expect(service.individual_products(identifier: individuals[0]).count).to eq(n)

    n.times do |i|
      service.subscribe_product_institution(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'])
    end
    expect(service.institution_products(identifier: institutions[0]['inst_id']).count).to eq(n)

    n.times do |i|
      service.add_product_component(product_identifier: products[0], component_identifier: components[i])
    end
    expect(service.product_components(identifier: products[0]).count).to eq(n)

    n.times do |i|
      service.add_product_component(product_identifier: products[i], component_identifier: components[0])
    end
    expect(service.component_products(identifier: components[0]).count).to eq(n)

    n.times do |i|
      service.unsubscribe_product_individual(product_identifier: products[0], individual_identifier: individuals[i])
      service.unsubscribe_product_individual(product_identifier: products[i], individual_identifier: individuals[0])
      service.unsubscribe_product_institution(product_identifier: products[0], institution_identifier: institutions[i]['inst_id'])
      service.unsubscribe_product_institution(product_identifier: products[i], institution_identifier: institutions[0]['inst_id'])
      service.remove_product_component(product_identifier: products[0], component_identifier: components[i])
      service.remove_product_component(product_identifier: products[i], component_identifier: components[0])
    end
    expect(service.product_individuals(identifier: products[0]).count).to eq(0)
    expect(service.individual_products(identifier: individuals[0]).count).to eq(0)
    expect(service.product_institutions(identifier: products[0]).count).to eq(0)
    expect(service.institution_products(identifier: institutions[0]['inst_id']).count).to eq(0)
    expect(service.product_components(identifier: products[0]).count).to eq(0)
    expect(service.component_products(identifier: components[0]).count).to eq(0)
  end
end
