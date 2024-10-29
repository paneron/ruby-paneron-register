# frozen_string_literal: true

RSpec.describe Paneron::Register::Register do
  let(:raw_register) do
    Paneron::Register::Raw::Register.new(
      "spec/fixtures/test-register",
    )
  end

  let(:register) do
    raw_register.to_lutaml
  end

  describe "#data_sets" do
    subject(:data_sets) { register.data_sets }
    its(:length) { is_expected.to eql(3) }

    describe "each item" do
      it "is a Paneron::Register::DataSet object" do
        data_sets.each do |data_set|
          expect(data_set).to be_instance_of(
            Paneron::Register::DataSet,
          )
        end
      end
    end
  end

  describe "#metadata" do
    subject(:metadata) { JSON.parse(register.metadata) }

    it { is_expected.to be_instance_of(Hash) }
    let(:expected_hash) do
      {
        "datasets" => { "reg-1" => true, "reg-2" => true, "reg-3" => true },
        "title" => "register",
      }
    end
    it { is_expected.to eql(expected_hash) }
  end
end
