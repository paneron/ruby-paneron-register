RSpec.describe PaneronRegistry::ItemClass do
  let(:item_class) do
    PaneronRegistry::ItemClass.new("spec/fixtures/test-registry", "reg-1",
                                   "item-class-1")
  end

  it "lists out item UUIDs" do
    expect(item_class.item_uuids).to contain_exactly(
      "00000000-0000-0000-0000-000000000001",
      "00000000-0000-0000-0000-000000000002",
      "00000000-0000-0000-0000-000000000003",
    )
  end

  it "lists out correct number of item YAML" do
    expect(item_class.item_yamls.length).to be(3)
  end

  it "retrieves item YAMLs as a Hash" do
    expect(item_class.item_yamls).to be_instance_of(Hash)
  end

  it "lists out item YAML" do
    item_class.item_yamls.each_pair do |_uuid, item|
      expect(item).to be_instance_of(Hash)
    end
  end

  it "retains item YAML properties" do
    item_class.item_yamls.each_pair do |_uuid, item|
      expect(item["id"]).to be_instance_of(String)
      expect(item["data"]).to be_instance_of(Hash)
      expect(item["data"]["blob1"]).to be_instance_of(String)
      expect(item["data"]["remarks"]).to be_instance_of(String)
      expect(item["data"]["dimensions"]).to be_instance_of(Array)
      expect(item["status"]).to be_instance_of(String)
      expect(item["dateAccepted"]).to be_instance_of(Time)
    end
  end
end
