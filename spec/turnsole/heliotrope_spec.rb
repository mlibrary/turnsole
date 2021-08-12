# frozen_string_literal: true

RSpec.describe Turnsole::Heliotrope do
  it "has a service" do
    expect(described_class::Service).not_to be nil
  end

  it "has product license types" do
    expect(described_class::LICENSE_TYPES).to contain_exactly(:full, :read)
  end

  it "encodes product license types" do
    described_class::LICENSE_TYPES.each do |license_type|
      expect(described_class.encode_license_type(license_type)).not_to eq "Greensub::License"
      expect(described_class.decode_license_type(described_class.encode_license_type(license_type))).to eq license_type
    end
    expect(described_class.encode_license_type(:unknown)).to eq "Greensub::License"
    expect(described_class.decode_license_type(described_class.encode_license_type(:unknown))).to be nil
  end

  it "decodes product license types" do
    expect(described_class.decode_license_type("Greensub::FullLicense")).to eq :full
    expect(described_class::LICENSE_TYPES.include?(described_class.decode_license_type("Greensub::FullLicense"))).to be true
    expect(described_class.decode_license_type("Greensub::ReadLicense")).to eq :read
    expect(described_class::LICENSE_TYPES.include?(described_class.decode_license_type("Greensub::ReadLicense"))).to be true
    expect(described_class.decode_license_type("Greensub::License")).to eq nil
    expect(described_class::LICENSE_TYPES.include?(described_class.decode_license_type("Greensub::License"))).to be false
  end
end
