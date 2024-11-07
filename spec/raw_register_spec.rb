# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::Register do
  describe ".generate" do
    let(:register_path) do
      "spec/fixtures/test-new-register"
    end

    let(:git_url) do
      "https://github.com/paneron/test-register.git"
    end

    it "generates a new register" do
      expect do
        described_class.generate(
          register_path,
          git_url: git_url,
        )
      end.to change { File.directory?(register_path) }.from(false).to(true)
    end

    it "returns a Raw::Register object" do
      expect(
        described_class.generate(
          register_path,
          git_url: git_url,
        ),
      ).to be_a(Paneron::Register::Raw::Register)
    end
  end

  let(:raw_register) do
    described_class.new(
      "spec/fixtures/test-register",
    )
  end

  describe "#sync" do
    # before do
    #   allow(raw_register).to receive(:pull_from_remote)
    # end

    describe "with a local-only register" do
      before do
        allow(raw_register).to receive(:remote?).and_return(false)
      end

      it "raises an error" do
        expect do
          raw_register.sync
        end.to raise_error(
          Paneron::Register::Error,
          "Cannot sync without a remote",
        )
      end
    end

    describe "with a remote register" do
      before do
        allow(raw_register).to receive(:remote?).and_return(true)
        allow(raw_register).to receive(:pull_from_remote)
        allow(raw_register).to receive(:add_changes_to_staging)
        allow(raw_register).to receive(:commit_changes)
        allow(raw_register).to receive(:has_unsynced_changes?)
        allow(raw_register).to receive(:push_commits_to_remote)
      end

      describe "with update: true" do
        it "calls pull_from_remote" do
          expect(raw_register).to receive(:pull_from_remote)
          raw_register.sync(update: true)
        end

        it "calls add_changes_to_staging" do
          expect(raw_register).to receive(:add_changes_to_staging)
          raw_register.sync(update: true)
        end

        describe "when has_unsynced_changes?" do
          before do
            allow(raw_register).to receive(:has_unsynced_changes?).and_return(true)
          end

          it "calls commit_changes" do
            expect(raw_register).to receive(:commit_changes)
            raw_register.sync(update: true)
          end

          it "calls push_commits_to_remote" do
            expect(raw_register).to receive(:push_commits_to_remote)
            raw_register.sync(update: true)
          end
        end
      end

      describe "with update: false" do
        it "does not call pull_from_remote" do
          expect(raw_register).to_not receive(:pull_from_remote)
          raw_register.sync(update: false)
        end

        it "calls add_changes_to_staging" do
          expect(raw_register).to receive(:add_changes_to_staging)
          raw_register.sync(update: false)
        end
      end
    end
  end

  describe "#save" do
    let(:old_register_path) do
      "spec/fixtures/test-register"
    end

    let(:new_register_path) do
      "spec/fixtures/test-register2"
    end

    it "returns a Raw::Register object" do
      expect(raw_register.save).to be_a(Paneron::Register::Raw::Register)
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
  end

  describe "#spawn_data_set" do
    let(:raw_register) do
      described_class.new(
        "spec/fixtures/new-register",
      ).save
    end

    describe "when adding the same data set multiple times" do
      let(:new_data_set_name) do
        "ds-a"
      end
      let(:action) do
        proc {
          3.times do
            raw_register.spawn_data_set(new_data_set_name)
          end
        }
      end

      it "creates a new DataSet object" do
        expect(&action).to change { raw_register.data_sets.length }.by(1)
      end

      it "creates a new DataSet object and modifies metadata" do
        expect(&action).to change { raw_register.metadata["datasets"].keys.length }.by(1)

        expect(raw_register.metadata["datasets"][new_data_set_name]).to be_truthy
      end
    end

    describe "when adding different data sets" do
      let(:new_data_set_names) do
        ["ds-a", "ds-b", "ds-c"]
      end

      let(:action) do
        proc {
          new_data_set_names.each { |ds| raw_register.spawn_data_set(ds) }
        }
      end

      it "creates new DataSet objects" do
        expect(&action).to change { raw_register.data_sets.length }.by(3)
      end

      it "creates new DataSet objects and modifies metadata datasets count" do
        expect(&action).to change { raw_register.metadata["datasets"].keys.length }.by(3)
      end

      it "creates new DataSet objects and modifies metadata datasets values" do
        expect(&action).to change {
          new_data_set_names.map { |ds| raw_register.metadata["datasets"][ds] }
        }.from([nil, nil, nil]).to([true, true, true])
      end
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

  describe "#title=" do
    it "updates the metadata title" do
      expect do
        raw_register.title = "new title"
      end.to change { raw_register.metadata["title"] }.from("register").to("new title")

      expect do
        raw_register.title = "new title"
      end.to_not(change { raw_register.metadata["title"] })

      expect do
        raw_register.title = "new title 2"
      end.to change { raw_register.title }.from("new title").to("new title 2")
    end
  end
end
