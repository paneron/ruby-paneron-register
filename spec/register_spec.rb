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
    subject(:metadata) { register.metadata }

    it { is_expected.to be_kind_of(Lutaml::Model::Serializable) }

    describe "#metadata.to_yaml" do
      subject(:parsed_yaml) { YAML.load(register.metadata.to_yaml) }

      let(:expected_hash) do
        {
          "datasets" => { "reg-1" => true, "reg-2" => true, "reg-3" => true },
          "title" => "register",
        }
      end
      it { is_expected.to eql(expected_hash) }
    end
  end
end
