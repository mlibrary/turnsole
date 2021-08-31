# frozen_string_literal: true

RSpec.describe Turnsole::Handle::Service do
  let(:invalidnoid) { 'invalidnoid' }
  let(:validnoid) { 'validnoid' }

  describe '#noid' do
    it { expect(described_class.noid(nil)).to be nil }
    it { expect(described_class.noid(described_class::HANDLE_NET_API_HANDLES + invalidnoid)).to be nil }
    it { expect(described_class.noid(described_class.path(invalidnoid))).to eq nil }
    it { expect(described_class.noid(described_class.path(validnoid))).to eq validnoid }
    it { expect(described_class.noid(described_class.url(validnoid))).to eq validnoid }
    it { expect(described_class.noid("#{described_class.url(validnoid)}?key=value")).to eq validnoid }
  end

  describe '#path' do
    it { expect(described_class.path(nil)).to eq described_class::FULCRUM_PREFIX }
    it { expect(described_class.path(invalidnoid)).to eq described_class::FULCRUM_PREFIX + invalidnoid }
    it { expect(described_class.path(validnoid)).to eq described_class::FULCRUM_PREFIX + validnoid }
  end

  describe '#url' do
    it { expect(described_class.url(nil)).to eq described_class::HANDLE_NET_PREFIX + described_class.path(nil) }
    it { expect(described_class.url(invalidnoid)).to eq described_class::HANDLE_NET_PREFIX + described_class.path(invalidnoid) }
    it { expect(described_class.url(validnoid)).to eq described_class::HANDLE_NET_PREFIX + described_class.path(validnoid) }
  end

  describe '#value' do
    let(:response) { double('response') }
    let(:body) { { responseCode: code, values: values }.to_json }
    let(:values) { [] }

    before do
      allow(Faraday).to receive(:get).with(described_class::HANDLE_NET_API_HANDLES + described_class.path(validnoid)).and_return(response)
      allow(response).to receive(:body).and_return(body)
      allow(response).to receive(:status).and_return(status)
    end

    context '1' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:code) { 1 }
      let(:values) { [{ data: { value: 'url' }, type: 'URL' }] }
      let(:status) { 200 }

      it { expect(described_class.value(validnoid)).to eq "url" }
    end

    context '1 : Success. (HTTP 200 OK)' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:code) { 1 }
      let(:values) { [{ data: { value: 'doi' }, type: 'DOI' }] }
      let(:status) { 200 }

      it { expect(described_class.value(validnoid)).to eq "1 : Success. (HTTP 200 OK)" }
    end

    context '2' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:code) { 2 }
      let(:status) { 500 }

      it { expect(described_class.value(validnoid)).to eq "2 : Error. Something unexpected went wrong during handle resolution. (HTTP 500 Internal Server Error)" }
    end

    context '100' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:code) { 100 }
      let(:status) { 404 }

      it { expect(described_class.value(validnoid)).to eq "100 : Handle Not Found. (HTTP 404 Not Found)" }
    end

    context '200' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:code) { 200 }
      let(:status) { 200 }

      it { expect(described_class.value(validnoid)).to eq "200 : Values Not Found. The handle exists but has no values (or no values according to the types and indices specified). (HTTP 200 OK)" }
    end
  end
end
