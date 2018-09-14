# frozen_string_literal: true
RSpec.describe Turnsole::HeliotropeService do
  heliotrope_service = described_class.new

  products_initial_count = heliotrope_service.products.count
  institutions_initial_count = heliotrope_service.institutions.count
  lessees_initial_count = heliotrope_service.lessees.count
  n = 3
  products = []
  institutions = []
  lessees = []
  components = []

  products_initial_count = heliotrope_service.products.count
  lessees_initial_count = heliotrope_service.lessees.count
  institutions_initial_count = heliotrope_service.institutions.count
  components_initial_count = heliotrope_service.components.count

  before(:all) do
    n.times do |i|
      products << "product#{i}"
      heliotrope_service.find_or_create_product(identifier: products[i])

      inst['inst_id'] = "instid_#{i}"
      inst['inst_name'] = "Institution #{i}"
      inst['entity_id'] = "entity_id_#{i}" if i.odd?  #test that field is optional
      institutions << inst
      if inst['entity_id']
          heliotrope_service.find_or_create_institution(identifier: inst['inst_id'], name: inst['inst_name'], entity_id: inst['entity_id'])
      else
          heliotrope_service.find_or_create_institution(identifier: inst['inst_id'], name: inst['inst_name'] )
      end
      lessees << inst['inst_id']
      components << "component#{i}"
      heliotrope_service.find_or_create_component(handle: components[i])
    end
  end

  after(:all) do
    n.times do |i|
      n.times do |j|
        heliotrope_service.unlink(product_identifier: products[i], lessee_identifier: lessees[j])
        heliotrope_service.unlink_component(product_identifier: products[i], handle: components[j])
      end
    end
    n.times do |i|
      heliotrope_service.delete_product(identifier: products[i])
      heliotrope_service.delete_lessee(identifier: lessees[i])
      heliotrope_service.delete_institution(identifier: lessees[i])
      heliotrope_service.delete_component(handle: components[i])
    end
  end

  it 'works' do
    expect(heliotrope_service.products.count).to eq(products_initial_count + n)
    expect(heliotrope_service.institutions.count).to eq(institutions_initial_count + n)
    expect(heliotrope_service.lessees.count).to eq(lessees_initial_count + n)
    expect(heliotrope_service.components.count).to eq(components_initial_count + n)

    n.times do |i|
      expect(heliotrope_service.product_lessees(product_identifier: products[i]).count).to eq(0)
      expect(heliotrope_service.lessee_products(lessee_identifier: lessees[i]).count).to eq(0)
      expect(heliotrope_service.product_components(product_identifier: products[i]).count).to eq(0)
      expect(heliotrope_service.component_products(handle: components[i]).count).to eq(0)
    end

    n.times do |i|
      if institutions[i]['entity_id']
        heliotrope_service.find_or_create_institution(identifier: institutions[i]['inst_id'], name: institutions[i]['inst_name'], entity_id: institutions[i]['entity_id'])
      else
        heliotrope_service.find_or_create_institution(identifier: institutions[i]['inst_id'], name: institutions[i]['inst_name'])
      end
      heliotrope_service.link(product_identifier: products[0], lessee_identifier: lessees[i])
    end
    expect(heliotrope_service.product_lessees(product_identifier: products[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.link(product_identifier: products[i], lessee_identifier: lessees[0])
    end
    expect(heliotrope_service.lessee_products(lessee_identifier: lessees[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.link_component(product_identifier: products[0], handle: components[i])
    end
    expect(heliotrope_service.product_components(product_identifier: products[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.link_component(product_identifier: products[i], handle: components[0])
    end
    expect(heliotrope_service.component_products(handle: components[0]).count).to eq(n)

    n.times do |i|
      heliotrope_service.unlink(product_identifier: products[0], lessee_identifier: lessees[i])
      heliotrope_service.unlink(product_identifier: products[i], lessee_identifier: lessees[0])
      heliotrope_service.unlink_component(product_identifier: products[0], handle: components[i])
      heliotrope_service.unlink_component(product_identifier: products[i], handle: components[0])
    end
    expect(heliotrope_service.product_lessees(product_identifier: products[0]).count).to eq(0)
    expect(heliotrope_service.lessee_products(lessee_identifier: lessees[0]).count).to eq(0)
    expect(heliotrope_service.component_products(handle: components[0]).count).to eq(0)
  end
end
