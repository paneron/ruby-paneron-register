# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::DataSet do
  describe "#initialize" do
    it "raises Paneron::Register::Error on invalid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-registerDOESNOTEXIST",
          "reg-1",
        )
      end.to raise_error Paneron::Register::Error
    end

    it "accepts a valid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-register",
          "reg-1",
        )
      end.not_to raise_error
    end
  end

  let(:data_set) do
    described_class.new("spec/fixtures/test-register", "reg-1")
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
