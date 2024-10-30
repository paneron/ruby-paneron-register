# frozen_string_literal: true

RSpec.describe Paneron::Register::ItemClass do
  let(:raw_item_class) do
    Paneron::Register::Raw::ItemClass.new(
      "spec/fixtures/test-register/reg-1/item-class-1",
    )
  end

  let(:item_class) do
    raw_item_class.to_lutaml
  end

  describe "#items" do
    it "retrieves all items" do
      expect(item_class.items.length).to be 3
    end

    it "returns an array of Paneron::Register::Item objects" do
      item_class.items.each do |item|
        expect(item).to be_instance_of(Paneron::Register::Item)
      end
    end
  end

  describe "#name" do
    it "retrieves the item class name" do
      expect(item_class.name).to eql("item-class-1")
    end
  end
end
