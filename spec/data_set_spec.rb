# frozen_string_literal: true

RSpec.describe Paneron::Register::DataSet do
  let(:raw_data_set) do
    Paneron::Register::Raw::DataSet.new(
      "spec/fixtures/test-register/reg-1",
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
        expect(item_class).to be_kind_of(Paneron::Register::ItemClass)
      end
    end
  end

  describe "#name" do
    it "retrieves the data set name" do
      expect(data_set.name).to eql("reg-1")
    end
  end

  describe "#metadata" do
    it "retrieves the data set metadata as a LutaML instance" do
      expect(data_set.metadata).to be_kind_of(Lutaml::Model::Serializable)
    end

    it "retrieves the data set metadata" do
      expect(data_set.metadata.to_yaml).to eql(<<~YAML)
        ---
        name: Test Data Set 1
        stakeholders:
        - roles:
          - submitter
          - manager
          - control-body-reviewer
          - control-body
          - owner
          name: Stake Holder 1
          gitServerUsername: stakeholder1
          contacts:
          - label: email
            value: stakeholder1@example.com
        - roles:
          - owner
          - manager
          name: Stake Holder 2
          gitServerUsername: stakeholder2
          affiliations:
            00000000-000a-000b-000c-000000000000:
              role: member
          contacts:
          - label: email
            value: stakeholder2@example.com
        version:
          id: '1.1'
          timestamp: '2024-01-01T07:00:00.000Z'
        contentSummary: "<p> This is a test data set. </p>"
        operatingLanguage:
          name: English
          country: N/A
          languageCode: eng
        organizations:
          00000000-000a-000b-000c-000000000000:
            name: Stake Holdings, Inc.
            logoURL: ''
      YAML
    end
  end

  describe "#paneron_metadata" do
    it "retrieves the Paneron data set metadata as a LutaML instance" do
      expect(data_set.paneron_metadata).to be_kind_of(Lutaml::Model::Serializable)
    end

    it "retrieves the Paneron data set metadata" do
      expect(YAML.load(data_set.paneron_metadata.to_yaml)).to eql({ "title" => "reg-1" })
    end
  end
end
