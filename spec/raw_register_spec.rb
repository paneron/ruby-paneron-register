# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::Register do
  let(:raw_register) do
    described_class.new(
      "spec/fixtures/test-register",
    )
  end

  describe "#save" do
    let(:old_register_path) do
      "spec/fixtures/test-register"
    end

    let(:new_register_path) do
      "spec/fixtures/test-register2"
    end

    it "saves to a new path" do
      expect do
        raw_register.register_path = new_register_path
        raw_register.save
      end.to change { File.directory?(new_register_path) }.from(false).to(true)
    end

    it "moves to a new path" do
      raw_register.register_path = old_register_path
      raw_register.save
      expect do
        raw_register.register_path = new_register_path
        raw_register.save
      end.to change {
               [
                 old_register_path,
                 new_register_path,
               ].map { |path| File.directory?(path) }
             }.from([true, false]).to([false, true])
    end

    it "creates new DataSet objects" do
      expect do
        raw_register.spawn_data_set("ds-a")
        raw_register.spawn_data_set("ds-b")
        raw_register.spawn_data_set("ds-c")
      end.to change { raw_register.data_sets.length }.by(3)
    end
  end

  describe "#spawn_data_set" do
    it "creates a new DataSet object" do
      expect do
        raw_register.spawn_data_set("ds-a")
        raw_register.spawn_data_set("ds-a")
        raw_register.spawn_data_set("ds-a")
      end.to change { raw_register.data_sets.length }.by(1)
    end

    it "creates new DataSet objects" do
      expect do
        raw_register.spawn_data_set("ds-a")
        raw_register.spawn_data_set("ds-b")
        raw_register.spawn_data_set("ds-c")
      end.to change { raw_register.data_sets.length }.by(3)
    end
  end

  describe "#add_data_sets" do
    let(:new_data_set) do
      Paneron::Register::Raw::DataSet.new(
        "random/nonexistent",
      )
    end

    it "adds the new DataSet object into its collection" do
      expect do
        raw_register.add_data_sets(new_data_set)
      end.to change { raw_register.data_sets.length }.by(1)
    end

    it "change the DataSet register to self" do
      expect do
        raw_register.add_data_sets(new_data_set)
      end.to change {
               new_data_set.register_path
             }.from("random").to(raw_register.register_path)
    end
  end

  describe "#path_valid?" do
    describe "with an invalid path" do
      subject do
        described_class.new("spec/fixtures/doesnotexist")
      end

      it { is_expected.to_not be_path_valid }
    end

    describe "with a valid path" do
      subject do
        described_class.new("spec/fixtures/test-register")
      end

      it { is_expected.to be_path_valid }
    end
  end

  describe "#initialize" do
    it "accepts a valid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-register",
        )
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

      it { is_expected.to be_instance_of(Set) }
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
