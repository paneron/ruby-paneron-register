# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::Item do
  describe "#valid?" do
    describe "with an invalid path" do
      subject do
        described_class.new(
          "1",
          "spec/fixtures/test-register/doesnotexist/item-class-1",
        )
      end

      it { is_expected.to_not be_path_valid }
    end

    describe "with a valid path" do
      subject do
        described_class.new(
          "00000000-0000-0000-0000-000000000001",
          "spec/fixtures/test-register/reg-1/item-class-1",
        )
      end

      it { is_expected.to be_path_valid }
    end
  end

  describe "#initialize" do
    it "accepts a valid path" do
      expect do
        described_class.new(
          "00000000-0000-0000-0000-000000000001",
          "spec/fixtures/test-register/reg-1/item-class-1",
        )
      end.not_to raise_error
    end
  end

  let(:item) do
    described_class.new(
      "00000000-0000-0000-0000-000000000001",
      "spec/fixtures/test-register/reg-1/item-class-1",
    )
  end

  describe "#to_lutaml" do
    subject(:to_lutaml) { item.to_lutaml }
    it { is_expected.to be_instance_of(Paneron::Register::Item) }
  end

  describe "#to_h" do
    subject(:to_h) { item.to_h }
    it { is_expected.to be_instance_of(Hash) }

    its(["id"]) { is_expected.to be_instance_of(String) }
    its(["data"]) { is_expected.to be_instance_of(Hash) }
    its(["data", "blob1"]) { is_expected.to be_instance_of(String) }
    its(["data", "remarks"]) { is_expected.to be_instance_of(String) }
    its(["data", "dimensions"]) { is_expected.to be_instance_of(Array) }
    its(["status"]) { is_expected.to be_instance_of(String) }
    its(["dateAccepted"]) { is_expected.to be_instance_of(Time) }
  end
end
