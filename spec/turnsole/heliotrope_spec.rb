# frozen_string_literal: true

RSpec.describe Turnsole::Heliotrope do
  it "has a service" do
    expect(described_class::Service).not_to be nil
  end

  it "has product access types" do
    expect(described_class::LICENSES).to contain_exactly(:full, :read, :none)
  end
end
