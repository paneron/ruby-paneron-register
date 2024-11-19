# frozen_string_literal: true

RSpec.describe Paneron::Register::Item do
  let(:raw_item) do
    Paneron::Register::Raw::Item.new(
      "00000000-0000-0001-0001-000000000001",
      "spec/fixtures/test-register/reg-1/item-class-1",
    )
  end

  let(:item) do
    raw_item.to_lutaml
  end

  describe "#id" do
    subject(:id) { item.id }
    it { is_expected.to eql("00000000-0000-0001-0001-000000000001") }
  end

  describe "#data" do
    let(:data_yaml) do
      YAML.safe_load(<<~YAML)
        identifier: 1
        name: Sample Item
        blob1: data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==
        remarks: >-
          Lorem ipsum
        dimensions:
          - 256
          - 256
      YAML
    end

    subject(:data) { item.data }

    it { is_expected.to eql(data_yaml.to_s) }
  end

  describe "#status" do
    subject(:status) { item.status }
    it { is_expected.to eql(Paneron::Register::ITEM_STATUSES[:VALID]) }
  end

  describe "#date_accepted" do
    let(:expected_date) do
      DateTime.parse("2024-01-01T00:00:00+00:00")
    end
    subject(:date_accepted) { item.date_accepted }
    it { is_expected.to eql(expected_date) }
  end
end
