# frozen_string_literal: true

RSpec.describe Turnsole::HeliotropeService do
  heliotrope_service = described_class.new

  n = 3
  products = []
  components = []
  individuals = []
  institutions = []

  products_initial_count = heliotrope_service.products.count
  components_initial_count = heliotrope_service.components.count
  individuals_initial_count = heliotrope_service.lessees.count
  institutions_initial_count = heliotrope_service.institutions.count

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    n.times do |i|
      products << "product#{i}"
      heliotrope_service.find_or_create_product(identifier: products[i])
      components << "component#{i}"
      heliotrope_service.find_or_create_component(handle: components[i])
      individuals << "individual#{i}"
      heliotrope_service.find_or_create_lessee(identifier: individuals[i])
      inst = {}
      inst['inst_id'] = "instid_#{i}"
      inst['inst_name'] = "Institution #{i}"
      inst['entity_id'] = "entity_id_#{i}" if i.odd? # test that field is optional
      institutions << inst
      if inst['entity_id']
        heliotrope_service.find_or_create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: inst['entity_id'])
      else
        heliotrope_service.find_or_create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: nil)
      end
    end
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    n.times do |i|
      n.times do |j|
        heliotrope_service.unlink_component(product_identifier: products[i], handle: components[j])
        heliotrope_service.unlink(product_identifier: products[i], lessee_identifier: individuals[j])
        heliotrope_service.unlink(product_identifier: products[i], lessee_identifier: institutions[j]['inst_id'])
      end
    end
    n.times do |i|
      heliotrope_service.delete_product(identifier: products[i])
      heliotrope_service.delete_component(handle: components[i])
      heliotrope_service.delete_lessee(identifier: individuals[i])
      heliotrope_service.delete_institution(identifier: institutions[i]['inst_id'])
    end
  end

  it 'works' do
    expect(heliotrope_service.products.count).to eq(products_initial_count + n)
    expect(heliotrope_service.components.count).to eq(components_initial_count + n)
    expect(heliotrope_service.lessees.count).to eq(individuals_initial_count + n)
    expect(heliotrope_service.institutions.count).to eq(institutions_initial_count + n)

    n.times do |i|
      expect(heliotrope_service.product_lessees(product_identifier: products[i]).count).to eq(0)
      expect(heliotrope_service.component_products(handle: components[i]).count).to eq(0)
      expect(heliotrope_service.product_components(product_identifier: products[i]).count).to eq(0)
      expect(heliotrope_service.lessee_products(lessee_identifier: individuals[i]).count).to eq(0)
      expect(heliotrope_service.lessee_products(lessee_identifier: institutions[i]).count).to eq(0)
    end

    n.times do |i|
      heliotrope_service.find_or_create_lessee(identifier: individuals[i])
      heliotrope_service.link(product_identifier: products[0], lessee_identifier: individuals[i])
    end
    expect(heliotrope_service.product_lessees(product_identifier: products[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.link(product_identifier: products[i], lessee_identifier: individuals[0])
    end
    expect(heliotrope_service.lessee_products(lessee_identifier: individuals[0]).count).to eq(n)

    n.times do |i|
      if institutions[i]['entity_id']
        heliotrope_service.find_or_create_institution(identifier: institutions[i]['inst_id'], name: institutions[i]['inst_name'], entity_id: institutions[i]['entity_id'])
      else
        heliotrope_service.find_or_create_institution(identifier: institutions[i]['inst_id'], name: institutions[i]['inst_name'], entity_id: nil)
      end
      heliotrope_service.link(product_identifier: products[0], lessee_identifier: institutions[i]['inst_id'])
    end
    expect(heliotrope_service.product_lessees(product_identifier: products[0]).count).to eq(2 * n)

    n.times do |i|
      heliotrope_service.link(product_identifier: products[i], lessee_identifier: institutions[0]['inst_id'])
    end
    expect(heliotrope_service.lessee_products(lessee_identifier: institutions[0]['inst_id']).count).to eq(n)

    n.times do |i|
      heliotrope_service.link_component(product_identifier: products[0], handle: components[i])
    end
    expect(heliotrope_service.product_components(product_identifier: products[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.link_component(product_identifier: products[i], handle: components[0])
    end
    expect(heliotrope_service.component_products(handle: components[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.unlink(product_identifier: products[0], lessee_identifier: individuals[i])
      heliotrope_service.unlink(product_identifier: products[i], lessee_identifier: individuals[0])
      heliotrope_service.unlink(product_identifier: products[0], lessee_identifier: institutions[i]['inst_id'])
      heliotrope_service.unlink(product_identifier: products[i], lessee_identifier: institutions[0]['inst_id'])
      heliotrope_service.unlink_component(product_identifier: products[0], handle: components[i])
      heliotrope_service.unlink_component(product_identifier: products[i], handle: components[0])
    end
    expect(heliotrope_service.product_lessees(product_identifier: products[0]).count).to eq(0)
    expect(heliotrope_service.lessee_products(lessee_identifier: individuals[0]).count).to eq(0)
    expect(heliotrope_service.lessee_products(lessee_identifier: institutions[0]['inst_id']).count).to eq(0)
    expect(heliotrope_service.component_products(handle: components[0]).count).to eq(0)
  end
end
