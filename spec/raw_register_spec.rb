# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::Register do
  describe "#initialize" do
    it "raises Paneron::Register::Error on invalid path" do
      expect do
        described_class.new("spec/fixtures/doesnotexist")
      end.to raise_error Paneron::Register::Error
    end

    it "accepts a valid path" do
      expect do
        described_class.new("spec/fixtures/test-register")
      end.not_to raise_error
    end
  end

  describe "with a valid register repository" do
    let(:register) do
      described_class.new("spec/fixtures/test-register")
    end

    describe "#metadata" do
      subject(:metadata) { register.metadata }
      let(:expected_hash) do
        {
          "datasets" => { "reg-1" => true, "reg-2" => true, "reg-3" => true },
          "title" => "register",
        }
      end
      it { is_expected.to eql(expected_hash) }
    end

    describe "#data_sets" do
      subject(:data_sets) { register.data_sets }

      it { is_expected.to be_instance_of(Hash) }
      its(:length) { is_expected.to eql(3) }

      describe "each item" do
        it "is a Paneron::Register::Raw::DataSet object" do
          data_sets.each_pair do |_data_set_name, data_set|
            expect(data_set).to be_instance_of(
              Paneron::Register::Raw::DataSet,
            )
          end
        end
      end
    end

    it "retrieves a specific data set object" do
      expect(register.data_sets("reg-1")).to be_instance_of(
        Paneron::Register::Raw::DataSet,
      )
    end

    describe "#data_set_names" do
      subject(:data_set_names) { register.data_set_names }

      it { is_expected.to be_instance_of(Array) }
      its(:length) { is_expected.to eql(3) }
      it {
        is_expected.to contain_exactly(
          "reg-1",
          "reg-2",
          "reg-3",
        )
      }
    end

    describe "#to_lutaml" do
      it "returns a Paneron::Register::Register object" do
        expect(register.to_lutaml).to be_instance_of(
          Paneron::Register::Register,
        )
      end
    end
  end
end
