# frozen_string_literal: true

RSpec.describe Paneron::Register::Raw::Register do
  it "detects invalid register path on initialization" do
    expect do
      described_class.new("spec/fixtures/doesnotexist")
    end.to raise_error Paneron::Register::Error
  end

  it "allows valid register path on initialization" do
    register =
      described_class.new("spec/fixtures/test-register")
    expect(register).to be_instance_of described_class
  end

  describe "with a valid register repository" do
    let(:register) do
      described_class.new("spec/fixtures/test-register")
    end

    it "gets register metadata" do
      expect(register.get_metadata).to eql(
        {
          "datasets" => { "reg-1" => true },
          "title" => "register",
        },
      )
    end

    it "retrieves data sets as a Hash" do
      expect(register.data_sets).to be_instance_of(Hash)
    end

    it "retrieves all data sets" do
      expect(register.data_sets.length).to be 3
    end

    it "retrieves data set objects" do
      register.data_sets.each_pair do |_data_set_name, data_set|
        expect(data_set).to be_instance_of(Paneron::Register::Raw::DataSet)
      end
    end

    it "retrieves a specific data set object" do
      expect(register.data_sets("reg-1")).to be_instance_of(
        Paneron::Register::Raw::DataSet,
      )
    end

    it "lists out data set names" do
      expect(register.data_set_names).to contain_exactly(
        "reg-1",
        "reg-2",
        "reg-3",
      )
    end

    it "gets data set metadata" do
      expect(register.data_sets("reg-1")).to be_instance_of(
        Paneron::Register::Raw::DataSet,
      )
    end
  end
end
