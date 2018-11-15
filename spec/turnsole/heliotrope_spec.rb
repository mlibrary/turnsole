# frozen_string_literal: true

RSpec.describe Turnsole::Heliotrope do
  it "has a service" do
    expect(described_class::Service).not_to be nil
  end
end
