# frozen_string_literal: true

RSpec.describe Paneron::Register::DataSet do
  let(:raw_data_set) do
    Paneron::Register::Raw::DataSet.new(
      "spec/fixtures/test-register",
      "reg-1",
    )
  end

  let(:data_set) do
    raw_data_set.to_lutaml
  end

  describe "#item_classes" do
    it "retrieves all item classes" do
      expect(data_set.item_classes.length).to be 3
    end

    it "returns an array of Paneron::Register::ItemClass objects" do
      data_set.item_classes.each do |item_class|
        expect(item_class).to be_instance_of(Paneron::Register::ItemClass)
      end
    end
  end

  describe "#name" do
    it "retrieves the data set name" do
      expect(data_set.name).to eql("reg-1")
    end
  end
end
