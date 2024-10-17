RSpec.describe Paneron::Register::RegisterRoot do
  it "detects invalid register path on initialization" do
    expect do
      Paneron::Register::RegisterRoot.new("spec/fixtures/doesnotexist")
    end.to raise_error Paneron::Register::Error
  end

  it "allows valid register path on initialization" do
    root = Paneron::Register::RegisterRoot.new("spec/fixtures/test-register")
    expect(root).to be_instance_of Paneron::Register::RegisterRoot
  end

  describe "with a valid register root repository" do
    let(:root) do
      Paneron::Register::RegisterRoot.new("spec/fixtures/test-register")
    end

    it "gets register root metadata" do
      expect(root.get_root_metadata).to eql(
        {
          "datasets" => { "reg-1" => true },
          "title" => "register",
        },
      )
    end

    it "retrieves registries as a Hash" do
      expect(root.registries).to be_instance_of(Hash)
    end

    it "retrieves all registries" do
      expect(root.registries.length).to be 3
    end

    it "retrieves register objects" do
      root.registries.each_pair do |_register_name, register|
        expect(register).to be_instance_of(Paneron::Register::Register)
      end
    end

    it "retrieves a specific register object" do
      expect(root.registries("reg-1")).to be_instance_of(Paneron::Register::Register)
    end

    it "lists out register names" do
      expect(root.register_names).to contain_exactly(
        "reg-1",
        "reg-2",
        "reg-3",
      )
    end

    it "gets register metadata" do
      expect(root.registries("reg-1")).to be_instance_of(
        Paneron::Register::Register,
      )
    end
  end
end
