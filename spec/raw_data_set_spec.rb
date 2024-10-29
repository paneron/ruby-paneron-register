# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::DataSet do
  let(:data_set) do
    described_class.new("spec/fixtures/test-register", "reg-1")
  end

  describe "item classes" do
    it "lists out item classes" do
      expect(data_set.item_class_names).to contain_exactly(
        "item-class-1",
        "item-class-2",
        "item-class-3",
      )
    end

    it "retrieves item classes as a Hash" do
      expect(data_set.item_classes).to be_instance_of(Hash)
    end

    it "retrieves item classes" do
      data_set.item_classes.each_pair do |_item_class_name, item_class|
        expect(item_class).to be_instance_of(Paneron::Register::Raw::ItemClass)
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
  end

  it "gets data_set metadata" do
    expect(data_set.get_metadata_yaml).to eql(
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
      },
    )
  end
end