RSpec.describe PaneronRegistry::RegistryRoot do
  it "detects invalid registry path on initialization" do
    expect do
      PaneronRegistry::RegistryRoot.new("spec/fixtures/doesnotexist")
    end.to raise_error PaneronRegistry::Error
  end

  it "allows valid registry path on initialization" do
    root = PaneronRegistry::RegistryRoot.new("spec/fixtures/test-registry")
    expect(root).to be_instance_of PaneronRegistry::RegistryRoot
  end

  describe "with a valid registry root repository" do
    let(:root) do
      PaneronRegistry::RegistryRoot.new("spec/fixtures/test-registry")
    end

    it "gets registry root metadata" do
      expect(root.get_root_metadata).to eql(
        {
          "datasets" => { "reg-1" => true },
          "title" => "registry",
        },
      )
    end

    it "retrieves registries as a Hash" do
      expect(root.registries).to be_instance_of(Hash)
    end

    it "retrieves all registries" do
      expect(root.registries.length).to be 3
    end

    it "retrieves registry objects" do
      root.registries.each_pair do |_registry_name, registry|
        expect(registry).to be_instance_of(PaneronRegistry::Registry)
      end
    end

    it "retrieves a specific registry object" do
      expect(root.registries("reg-1")).to be_instance_of(PaneronRegistry::Registry)
    end

    it "lists out registry names" do
      expect(root.registry_names).to contain_exactly(
        "reg-1",
        "reg-2",
        "reg-3",
      )
    end

    it "gets registry metadata" do
      expect(root.registries("reg-1")).to be_instance_of(
        PaneronRegistry::Registry,
      )
    end
  end
end
