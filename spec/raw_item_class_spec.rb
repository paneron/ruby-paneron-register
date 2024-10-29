# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::ItemClass do
  describe "#initialize" do
    it "raises Paneron::Register::Error on invalid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-register/doesnotexist",
          "item-class-1",
        )
      end.to raise_error Paneron::Register::Error
    end

    it "accepts a valid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-register/reg-1",
          "item-class-1",
        )
      end.not_to raise_error
    end
  end

  let(:item_class) do
    described_class.new(
      "spec/fixtures/test-register/reg-1",
      "item-class-1",
    )
  end

  describe "#item_uuids" do
    subject(:item_uuids) { item_class.item_uuids }
    it {
      is_expected.to contain_exactly(
        "00000000-0000-0000-0000-000000000001",
        "00000000-0000-0000-0000-000000000002",
        "00000000-0000-0000-0000-000000000003",
      )
    }
  end

  describe "#items" do
    subject(:items) { item_class.items }
    it { is_expected.to be_instance_of(Hash) }
    its(:length) { is_expected.to eql(3) }

    describe "each item" do
      it "is a Hash" do
        items.each_pair do |_uuid, item|
          expect(item).to be_instance_of(Paneron::Register::Raw::Item)
        end
      end
    end
  end
end
