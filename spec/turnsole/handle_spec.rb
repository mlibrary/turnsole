# frozen_string_literal: true

RSpec.describe Turnsole::Handle do
  it "has a service" do
    expect(described_class::Service).not_to be nil
  end
end
