# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::DataSet do
  let(:raw_register) do
    Paneron::Register::Raw::Register.new(
      "spec/fixtures/test-register",
    )
  end

  describe "#data_set_name=" do
    let(:old_data_set_name) do
      "ds-a"
    end

    let(:new_data_set_name) do
      "ds-b"
    end

    let(:raw_data_set) do
      ds = raw_register.spawn_data_set(old_data_set_name)
      expect(ds.data_set_name).to eql(old_data_set_name)
      expect(ds.title).to eql(old_data_set_name)
      ds
    end

    it "changes data_set_name" do
      expect do
        raw_data_set.data_set_name = new_data_set_name
      end.to change {
               raw_data_set.data_set_name
             }.from(old_data_set_name).to(new_data_set_name)
    end

    it "changes panerondataset title" do
      expect do
        raw_data_set.data_set_name = new_data_set_name
      end.to change {
               raw_data_set.title
             }.from(old_data_set_name).to(new_data_set_name)
    end
  end

  describe "#save" do
    let(:old_data_set_name) do
      "ds-a"
    end

    let(:new_data_set_name) do
      "ds-b"
    end

    let(:raw_data_set) do
      ds = raw_register.spawn_data_set(old_data_set_name)
      ds
    end

    let(:old_data_set_path) do
      File.join(
        raw_register.register_path,
        old_data_set_name,
      )
    end

    let(:new_data_set_path) do
      File.join(
        raw_register.register_path,
        new_data_set_name,
      )
    end

    it "saves to a new path" do
      expect do
        raw_data_set.data_set_name = new_data_set_name
        raw_data_set.save
      end.to change { File.directory?(new_data_set_path) }.from(false).to(true)
    end

    it "moves to a new path" do
      raw_data_set.data_set_name = old_data_set_name
      raw_data_set.save
      expect do
        raw_data_set.data_set_name = new_data_set_name
        raw_data_set.save
      end.to change {
               [
                 old_data_set_path,
                 new_data_set_path,
               ].map { |path| File.directory?(path) }
             }.from([true, false]).to([false, true])
    end
  end

  describe "#add_item_classes" do
    let(:raw_data_set) do
      ds = raw_register.spawn_data_set("asdfnonexist")
      ds
    end

    let(:new_item_class) do
      Paneron::Register::Raw::ItemClass.new(
        "random/nonexistent/ic-a",
      )
    end

    it "adds the new ItemClass object into its collection" do
      expect do
        raw_data_set.add_item_classes(new_item_class)
      end.to change { raw_data_set.item_classes.length }.by(1)
    end

    it "change the ItemClass's DataSet to self" do
      expect do
        raw_data_set.add_item_classes(new_item_class)
      end.to change {
               new_item_class.data_set_path
             }.from("random/nonexistent").to(raw_data_set.data_set_path)
    end
  end

  describe "#spawn_item_class" do
    let(:raw_data_set) do
      ds = raw_register.spawn_data_set("asdfnonexist")
      ds
    end

    describe "when adding the item class multiple times" do
      let(:new_item_class_name) do
        "ic-a"
      end
      let(:action) do
        proc {
          3.times do
            raw_data_set.spawn_item_class(new_item_class_name)
          end
        }
      end

      it "creates a new ItemClass object" do
        expect(&action).to change { raw_data_set.item_classes.length }.by(1)
      end

      it "creates a new ItemClass object and modifies #item_class_names" do
        expect(&action).to change { raw_data_set.item_class_names.length }.by(1)
      end
    end

    describe "when adding different item classes" do
      let(:new_item_class_names) do
        ["ic-a", "ic-b", "ic-c"]
      end

      let(:action) do
        proc {
          new_item_class_names.each { |ic| raw_data_set.spawn_item_class(ic) }
        }
      end

      it "creates new ItemClass objects" do
        expect(&action).to change { raw_data_set.item_classes.length }.by(3)
      end

      it "creates a new ItemClass object and modifies #item_class_names" do
        expect(&action).to change { raw_data_set.item_class_names.length }.by(3)
      end
    end
  end

  describe "#path_valid?" do
    describe "with an invalid path" do
      subject do
        described_class.new("spec/fixtures/test-register/doesnotexist")
      end

      it { is_expected.to_not be_path_valid }
    end

    describe "with a valid path" do
      subject do
        described_class.new("spec/fixtures/test-register/reg-1")
      end

      it { is_expected.to be_path_valid }
    end
  end

  describe "#initialize" do
    it "accepts a valid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-register/reg-1",
        )
      end.not_to raise_error
    end
  end

  let(:data_set) do
    described_class.new("spec/fixtures/test-register/reg-1")
  end

  describe "#item_class_names" do
    subject(:item_class_names) { data_set.item_class_names }
    it {
      is_expected.to contain_exactly("item-class-1", "item-class-2",
                                     "item-class-3")
    }
  end

  describe "#item_classes" do
    subject(:item_classes) { data_set.item_classes }

    it { is_expected.to be_instance_of(Hash) }

    describe "each item" do
      it "is an instance of Paneron::Register::Raw::ItemClass" do
        item_classes.each_pair do |_item_class_name, item_class|
          expect(item_class).to be_instance_of(
            Paneron::Register::Raw::ItemClass,
          )
        end
      end
    end
  end

  it "lists out item UUIDs" do
    expect(data_set.item_uuids.length).to be(9)
  end

  it "retrieves a specific item class" do
    expect(data_set.item_classes("item-class-1")).to be_instance_of(
      Paneron::Register::Raw::ItemClass,
    )
  end

  describe "#metadata" do
    subject(:metadata) { data_set.metadata }
    let(:expected_hash) do
      {
        "contentSummary" => "<p> This is a test data set. </p>",
        "name" => "Test Data Set 1",
        "operatingLanguage" => {
          "country" => "N/A",
          "languageCode" => "eng",
          "name" => "English",
        },
        "organizations" => {
          "00000000-000a-000b-000c-000000000000" => {
            "logoURL" => "",
            "name" => "Stake Holdings, Inc.",
          },
        },
        "stakeholders" => [
          {
            "contacts" => [
              {
                "label" => "email",
                "value" => "stakeholder1@example.com",
              },
            ],
            "gitServerUsername" => "stakeholder1",
            "name" => "Stake Holder 1",
            "roles" => ["submitter",
                        "manager",
                        "control-body-reviewer",
                        "control-body",
                        "owner"],
          },
          {
            "affiliations" => {
              "00000000-000a-000b-000c-000000000000" => {
                "role" => "member",
              },
            },
            "contacts" => [{
              "label" => "email",
              "value" => "stakeholder2@example.com",
            }],
            "gitServerUsername" => "stakeholder2",
            "name" => "Stake Holder 2",
            "roles" => ["owner", "manager"],
          },
        ],
        "version" => {
          "id" => "1.1",
          "timestamp" => Time.parse("2024-01-01 07:00:00.000000000 +0000"),
        },
      }
    end

    it { is_expected.to eql(expected_hash) }
  end
end
