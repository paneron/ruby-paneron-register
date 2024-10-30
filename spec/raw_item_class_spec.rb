# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::ItemClass do
  describe "#path_valid?" do
    describe "with an invalid path" do
      subject do
        described_class.new("spec/fixtures/test-register/doesnotexist/item-class-1")
      end

      it { is_expected.to_not be_path_valid }
    end

    describe "with a valid path" do
      subject do
        described_class.new("spec/fixtures/test-register/reg-1/item-class-1")
      end

      it { is_expected.to be_path_valid }
    end
  end

  describe "#initialize" do
    it "accepts a valid path" do
      expect do
        described_class.new(
          "spec/fixtures/test-register/reg-1/item-class-1",
        )
      end.not_to raise_error
    end
  end

  describe "#save" do
    let(:data_set) do
      ds = Paneron::Register::Raw::DataSet.new(
        "spec/fixtures/test-register/ds-1",
      )
      ds.save
      ds
    end

    let(:old_item_class_name) do
      "ic-a"
    end

    let(:new_item_class_name) do
      "ic-b"
    end

    let(:item_class) do
      data_set.spawn_item_class(old_item_class_name)
    end

    let(:old_item_class_path) do
      File.join(
        data_set.data_set_path,
        old_item_class_name,
      )
    end

    let(:new_item_class_path) do
      File.join(
        data_set.data_set_path,
        new_item_class_name,
      )
    end

    it "saves to a new path" do
      expect do
        item_class.item_class_name = new_item_class_name
        item_class.save
      end.to change { File.directory?(new_item_class_path) }.from(false).to(true)
    end

    it "moves to a new path" do
      item_class.item_class_name = old_item_class_name
      item_class.save
      expect do
        item_class.item_class_name = new_item_class_name
        item_class.save
      end.to change {
               [
                 old_item_class_path,
                 new_item_class_path,
               ].map { |path| File.directory?(path) }
             }.from([true, false]).to([false, true])
    end
  end

  describe "#add_items" do
    let(:new_item) do
      Paneron::Register::Raw::Item.new(
        "000z",
        "random/nonexistent/ic-a",
      )
    end

    it "adds the new Item object into its collection" do
      expect do
        item_class.add_items(new_item)
      end.to change { item_class.items.length }.by(1)
    end

    it "change the Item's ItemClass to self" do
      expect do
        item_class.add_items(new_item)
      end.to change {
               new_item.item_class_path
             }.from("random/nonexistent/ic-a").to(item_class.item_class_path)
    end
  end

  describe "#spawn_item" do
    it "creates a new Item object" do
      expect do
        item_class.spawn_item("000a")
        item_class.spawn_item("000a")
        item_class.spawn_item("000a")
      end.to change { item_class.items.length }.by(1)
    end

    it "creates new Item objects" do
      expect do
        item_class.spawn_item("000a")
        item_class.spawn_item("000b")
        item_class.spawn_item("000c")
      end.to change { item_class.items.length }.by(3)
    end
  end

  let(:item_class) do
    described_class.new(
      "spec/fixtures/test-register/reg-1/item-class-1",
    )
  end

  describe "#item_uuids" do
    subject(:item_uuids) { item_class.item_uuids }
    it {
      is_expected.to contain_exactly(
        "00000000-0000-0000-0000-000000000001",
        "00000000-0000-0000-0000-000000000002",
        "00000000-0000-0000-0000-000000000003",
      )
    }
  end

  describe "#items" do
    subject(:items) { item_class.items }
    it { is_expected.to be_instance_of(Hash) }
    its(:length) { is_expected.to eql(3) }

    describe "each item" do
      it "is a Hash" do
        items.each_pair do |_uuid, item|
          expect(item).to be_instance_of(Paneron::Register::Raw::Item)
        end
      end
    end
  end
end
