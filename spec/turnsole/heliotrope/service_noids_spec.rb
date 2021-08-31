# frozen_string_literal: true

RSpec.describe Turnsole::Heliotrope::Service do
  service = described_class.new

  # These rely on this Monograph on preview: https://heliotrope-preview.hydra.lib.umich.edu/concern/monographs/kw52j9144?locale=en
  describe 'noids' do
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
end
