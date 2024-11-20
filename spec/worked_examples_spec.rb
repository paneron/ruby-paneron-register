# frozen_string_literal: true

# In this document, you may find examples of how to use Paneron::Register.

# ====
# = Examples

# The following examples assume this preamble:

# [source,ruby]
# ----
# require "paneron/register"
# include Paneron::Register
# ----

include Paneron::Register

RSpec.describe "Paneron::Register" do
  before do
    allow(Raw::Register).to receive(:local_cache_path).and_return("cache")
  end

  describe "Creating a register" do
    describe "from scratch" do
      let(:register) do
        Raw::Register.generate(
          "./local/path/to/directory/can/be/empty",
        )
      end

      it "generates a new register with a new data set" do
        expect do
          # Create a data set
          register.spawn_data_set("data_set_name")

          register.save
        end.to change {
                 [
                   "./local/path/to/directory/can/be/empty",
                   "./local/path/to/directory/can/be/empty/data_set_name",
                 ].map do |dir|
                   File.directory?(dir)
                 end
               }.from([false, false]).to([true, true])
      end

      describe "Adding a Git URL" do
      end
    end

    # Allow the only example to hit the real world (GitHub):
    describe "from an existing Git repository" do
      let(:git_url) { "https://github.com/isogr/registry" }
      let(:register) do
        Raw::Register.from_git(git_url)
      end

      before do
        # For tests, replace git cloning with Git.init
        allow(Raw::Register).to receive(:clone_git_repo) do |_git_url, repo_path|
          require "git"
          Git.init(repo_path)
        end
      end

      it "loads a register from a Git repository" do
        expect do
          register
        end.to change {
          File.directory?(Raw::Register.calculate_repo_cache_path(git_url))
        }.from(false).to(true)
      end
    end
  end

  describe "Register an item class" do
    let(:register) do
      Raw::Register.generate(
        "./a/new/register",
      )
    end

    let(:data_set) do
      register.spawn_data_set("register-a").save
    end

    let(:new_item_class_name) do
      "itemclass-a"
    end

    it "generates a new item class" do
      expect do
        data_set.spawn_item_class(new_item_class_name)
      end.to change {
        data_set.item_class_names.include?(new_item_class_name)
      }.from(false).to(true)
    end
  end

  describe "Store a file in the item" do
    let(:register) do
      Raw::Register.generate(
        "./a/new/register",
      )
    end

    let(:data_set) do
      register.spawn_data_set("register-a").save
    end

    let(:item_class) do
      data_set.spawn_item_class("itemclass-a").save
    end

    it "generates a new item" do
      expect do
        item_class.spawn_item
      end.to change {
        item_class.item_uuids.length
      }.by(1)
    end

    describe "with a new item" do
      let(:item) do
        item_class.spawn_item.save
      end

      let(:file) do
        # Create a "file" from random string.
        require "securerandom"
        SecureRandom.uuid
      end

      it "can store arbitrary file in the new item" do
        expect do
          item.data = file
          item.save
        end.to change {
          item.data
        }.from(nil).to(file)
      end
    end
  end

  describe "Write the item to register (sync local to remote)" do
    let(:register) do
      _r = Raw::Register.generate(
        "./a/new/register",
      )

      # Simulating adding git_url after the fact:
      _r.git_url = "https://test"
      _r.save
    end

    let(:data_set) do
      register.spawn_data_set("register-a").save
    end

    let(:item_class) do
      data_set.spawn_item_class("itemclass-a").save
    end

    let(:file) do
      # Create a "file" from random string.
      require "securerandom"
      SecureRandom.uuid
    end

    let(:item) do
      _i = item_class.spawn_item
      _i.data = file
      _i.save
    end

    before do
      allow(register).to receive(:push_commits_to_remote)
      allow(register).to receive(:pull_from_remote)
      allow(register).to receive(:commit_changes)
      allow(register).to receive(:save_sequence)
      allow(register).to receive(:has_unsynced_changes?).and_call_original
      register.sync(update: true)
    end

    subject { register }

    it { is_expected.to have_received(:has_unsynced_changes?).once }
    it { is_expected.to have_received(:push_commits_to_remote).once }
    it { is_expected.to_not have_received(:save_sequence) }
    it { is_expected.to_not have_received(:commit_changes) }
    it { is_expected.to have_received(:pull_from_remote).once }
  end

  describe "Fetch the item for use" do
    let(:git_url) do
      "https://test"
    end

    let(:register) do
      Raw::Register.generate(
        "./a/new/register",
        git_url: git_url,
      )
    end

    let(:data_set) do
      register.spawn_data_set("register-a").save
    end

    let(:item_class) do
      data_set.spawn_item_class("itemclass-a").save
    end

    let(:file) do
      # Create a "file" from random string.
      require "securerandom"
      SecureRandom.uuid
    end

    let(:item) do
      _i = item_class.spawn_item
      _i.data = file
      _i.save
    end

    before do
      # For tests, replace git cloning with Git.init
      allow(Raw::Register).to receive(:clone_git_repo) do |_git_url, repo_path|
        require "git"
        Git.init(repo_path)
      end

      allow(register).to receive(:push_commits_to_remote)
      allow(register).to receive(:pull_from_remote)
      allow(register).to receive(:commit_changes)
      allow(register).to receive(:has_unsynced_changes?).and_call_original
    end

    describe "given an item UUID" do
      subject { register.items(item.uuid) }
      its(:data) { is_expected.to eq(item.data) }
      its(:status) { is_expected.to eq(item.status) }
      its(:date_accepted) { is_expected.to eq(item.date_accepted) }
    end

    describe "obtain the file data from the item" do
      it "retrieves the file" do
        expect(register.items(item.uuid).data).to eq(file)
      end
    end
  end
end
