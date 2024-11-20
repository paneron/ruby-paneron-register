# frozen_string_literal: true

require "yaml"
require "set"

module Paneron
  module Register
    module Raw
      class Register
        include Writeable
        include Validatable

        attr_reader :git_client, :git_url, :git_branch, :git_remote_name
        attr_accessor :register_path

        def initialize(
          register_path,
          git_url: nil,
          update_git: nil,
          git_remote_name: nil,
          git_branch: nil
        )
          @old_git_url = @git_url = git_url
          @register_path = register_path
          setup_git(
            git_url: git_url,
            path: register_path,
            git_remote_name: git_remote_name,
            git_branch: git_branch,
            update: update_git,
          )

          @old_path = @register_path
          @data_sets = {}
          @item_classes = {}
          @items = {}
          @metadata = nil
          @git_save_fn = proc {}
        end

        # Defer all mkdir until #save_sequence
        def setup_git(
          git_url: nil,
          path: nil,
          git_remote_name: nil,
          git_branch: nil,
          update: nil
        )
          require "git"
          self.class.setup_cache_path

          @git_remote_name = if git_remote_name.nil? || git_remote_name.empty?
                               "origin"
                             else
                               git_remote_name
                             end

          @git_branch = if git_branch.nil? || git_branch.empty?
                          "main"
                        else
                          git_branch
                        end

          if git_url.nil? && path.nil?
            raise Paneron::Register::Error,
                  "Must supply either git_url or path."
          end

          repo_path = if path.nil?
                        self.class.calculate_repo_cache_path(git_url)
                      else
                        path
                      end

          #------------------------------------
          #     | dir   | Git.open(dir)
          # no  |exists |
          # git |-------|----------------------
          # url | dir   | mkdirp &&
          #     |!exists| Git.open(dir) ? Git.init(dir)
          #------------------------------------
          #     | dir   | Git.open(dir) &&
          # has |exists | remote? ? check remote : add remote
          # git |-------|----------------------
          # url | dir   | Git.clone(url, dir) ||
          #     |!exists| mkdirp && Git.open(dir) ? Git.init(dir) &&
          #     |       | add remote
          #------------------------------------

          if git_url.nil?
            if File.exist?(repo_path)
              # No remote, but local repo path exists.
              # Simply open it as a Git repo.
              @git_save_fn = nil

              begin
                @git_client = self.class.open_git_repo(repo_path)
                log_change_git_remote(nil)
                change_git_remote(nil)
              rescue ArgumentError => e
                if /not in a git working tree/.match?(e.message)
                  @git_save_fn = proc {
                    @git_client = self.class.init_git_repo(repo_path,
                                                           initial_branch: @git_branch)
                    log_change_git_remote(nil)
                    change_git_remote(nil)
                  }
                else
                  raise e
                end
              end
            else
              # No remote, and local repo path does not exist.
              git_init_fn = proc {
                FileUtils.mkdir_p(repo_path)
                @git_client = self.class.init_git_repo(repo_path, initial_branch: @git_branch)
                log_change_git_remote(nil)
                change_git_remote(nil)
              }

              # Defer creation of directory until #save_sequence
              @git_client = nil
              @git_save_fn = git_init_fn

            end
          elsif File.exist?(repo_path)
            # Has remote, as well as local repo path.
            @git_save_fn = nil

            git_fn = proc {
              # Check if remote matches the provided git_url
              if !@git_client.remote(@git_remote_name).url.nil? && @git_client.remote(@git_remote_name).url != git_url

                raise Paneron::Register::Error,
                      "Git remote @ #{clone_path} already exists " \
                      "(#{@git_client.remote(@git_remote_name).url}) " \
                      "but does not match provided URL (#{git_url}).\n" \
                      "Instead, use `r = #{self}.new(\"#{path}\")` and "\
                      "`r.git_url = \"#{git_url}\"` to change its Git URL."
              end
              log_change_git_remote(git_url)
              change_git_remote(git_url)

              # Pull-rebase to update it
              if update
                @git_client.pull(
                  nil, nil, rebase: true
                )
              end
            }

            begin
              @git_client = self.class.open_git_repo(repo_path)
              git_fn.call
            rescue ArgumentError => e
              if /not in a git working tree/.match?(e.message)
                @git_save_fn = proc {
                  @git_client = self.class.init_git_repo(repo_path,
                                                         initial_branch: @git_branch)
                  git_fn.call
                }
              else
                raise e
              end
            end

          else
            git_clone_fn = proc {
              begin
                @git_client = self.class.clone_git_repo(git_url, repo_path)
                change_git_remote(git_url)
              rescue Git::TimeoutError => e
                e.result.tap do |_r|
                  warn "Timed out trying to clone #{repo_url}."
                  raise e
                end
              end
            }

            # rubocop:disable Style/IdenticalConditionalBranches
            # URL changed. Use save fn.
            if git_url_changed?(git_url)
              log_change_git_remote(git_url)
              @git_client = nil
              @git_save_fn = git_clone_fn
            else
              # Path is nil.  Clone repo.
              log_change_git_remote(git_url)
              @git_save_fn = nil
              git_clone_fn.call
            end
            # rubocop:enable Style/IdenticalConditionalBranches
          end
        end

        def register_yaml_path
          File.join(register_path,
                    REGISTER_METADATA_FILENAME)
        end

        def parent; nil; end

        def self.name
          "Register"
        end

        def save_sequence
          # Save self
          require "fileutils"

          # Move old register to new path
          if File.directory?(@old_path) && @old_path != self_path
            FileUtils.mv(@old_path, self_path)
            @old_path = self_path
          else
            FileUtils.mkdir_p(self_path)
          end

          if @git_client.nil?
            @git_save_fn.call
          end

          if @metadata.nil? || @metadata.empty?
            File.write(register_yaml_path, self.class.metadata_template.to_yaml)
          else
            File.write(register_yaml_path, metadata.to_yaml)
          end

          # Save data sets
          data_set_names.each do |data_set_name|
            new_thing = data_sets(data_set_name)
            new_thing.register = self
            new_thing.save
          end
          # else
          #   raise Paneron::Register::Error, "Register is not valid"
          # end
        end

        def title=(new_title)
          metadata["title"] = new_title.to_s
        end

        def title
          metadata["title"]
        end

        def self_path
          register_path
        end

        # TODO: Expand validation to include data set metadata?
        # TODO: What is considered valid?
        def is_valid?
          true
        end

        def add_data_sets(*new_data_sets)
          new_data_sets = [new_data_sets] unless new_data_sets.is_a?(Enumerable)
          new_data_sets.each do |data_set|
            data_set.set_register(self)
            @data_sets[data_set.data_set_name] = data_set
            metadata["datasets"].merge!(
              { data_set.data_set_name => true },
            )
          end
        end

        def spawn_data_set(
          data_set_name,
          metadata: {},
          paneron_metadata: {}
        )
          new_data_set = Paneron::Register::Raw::DataSet.new(
            File.join(register_path, data_set_name),
            register: self,
          )

          new_data_set.merge_metadata(metadata)
          new_data_set.merge_paneron_metadata(paneron_metadata)
          add_data_sets(new_data_set)

          new_data_set
        end

        def self.local_cache_path
          case RUBY_PLATFORM
          when /darwin/
            File.join(
              `command getconf DARWIN_USER_CACHE_DIR`.chomp,
              "com.paneron.ruby-paneron-register",
            )
          else
            File.join(
              Dir.exist?(ENV["XDG_CACHE_HOME"].to_s) ? ENV["XDG_CACHE_HOME"] : "~/.cache",
              "ruby-paneron-register",
            )
          end
        end

        def self.setup_cache_path
          if !Dir.exist?(local_cache_path)
            require "fileutils"
            FileUtils.mkdir_p(local_cache_path)
          end
        end

        def self.calculate_repo_cache_hash(repo_url)
          require "digest"
          require "base64"
          digest = [Digest::SHA1.hexdigest(repo_url)].pack("H*")
          Base64.encode64(digest).tr("+/= ", "_-")[0..16]
        end

        # Basically .new but calls #save at the end
        def self.generate(
          register_path,
          git_url: nil,
          git_branch: nil,
          git_remote_name: nil
        )
          new(
            register_path,
            git_url: git_url,
            git_branch: git_branch,
            git_remote_name: git_remote_name,
          ).save
        end

        def self.calculate_repo_cache_name(repo_url)
          "#{File.basename(repo_url)}-#{calculate_repo_cache_hash(repo_url)}"
        end

        def self.calculate_repo_cache_path(repo_url)
          repo_cache_name =
            calculate_repo_cache_name(repo_url)

          # Check if repo is already cloned
          File.join(local_cache_path, repo_cache_name)
        end

        def git_url=(new_url)
          setup_git(git_url: new_url, path: self_path)
        end

        def self.from_git(repo_url, path: nil, update: true)
          new(path, git_url: repo_url, update_git: true)
        end

        REGISTER_METADATA_FILENAME = "/paneron.yaml"

        def self.validate_path_before_saving
          false
        end

        def self.validate_path(path)
          unless File.exist?(path)
            raise Paneron::Register::Error,
                  "#{name} path (#{path}) does not exist"
          end

          unless File.directory?(path)
            raise Paneron::Register::Error,
                  "#{name} path (#{path}) is not a directory"
          end

          register_file = File.join(
            path, REGISTER_METADATA_FILENAME
          )
          unless File.exist?(register_file)
            raise Paneron::Register::Error,
                  "Register metadata file (#{register_file}) does not exist"
          end
        end

        def to_lutaml
          Paneron::Register::Register.new(
            data_sets: data_set_lutamls,
            metadata: metadata.to_json,
          )
        end

        def data_set_names(refresh: false)
          if refresh || @data_sets.empty?
            Dir.glob(
              File.join(
                register_path,
                "*#{Paneron::Register::Raw::DataSet::DATA_SET_METADATA_FILENAME}",
              ),
            )
              .map do |file|
              File.basename(File.dirname(file))
            end.to_set
          else
            @data_sets.keys
          end
          # @data_set_names ||= Dir.glob(
        end

        def data_set_path(data_set_name)
          File.join(register_path, data_set_name)
        end

        def metadata
          @metadata ||= YAML.safe_load_file(
            register_yaml_path,
            permitted_classes: [Time, Date, DateTime],
          )
        end

        def metadata=(metadata)
          @metadata = metadata
        end

        def data_sets(data_set_name = nil, refresh: false)
          if data_set_name.nil?
            @data_sets = if !refresh && !@data_sets.empty?
                           @data_sets
                         else
                           data_set_names(refresh: refresh).reduce({}) do |acc, data_set_name|
                             acc[data_set_name] = data_sets(data_set_name)
                             acc
                           end
                         end
          elsif refresh
            data_sets(refresh: true)[data_set_name]
          else
            @data_sets[data_set_name] ||=
              Paneron::Register::Raw::DataSet.new(
                File.join(register_path, data_set_name),
                register: self,
              )
          end
        end

        # @return Hash of { data_set_name => { item_class_name => ItemClass }}
        #   - ["data_set_name"]["item_class_name"]
        def item_classes(data_set_name = nil, item_class_name = nil, refresh: false)
          if data_set_name.nil? && item_class_name.nil?
            @item_classes = if !refresh && !@item_classes.empty?
                              @item_classes
                            else
                              data_sets.reduce({}) do |acc, (ddata_set_name, data_set)|
                                acc[ddata_set_name] ||= {}
                                data_set.item_class_names.each do |item_klass_name|
                                  acc[ddata_set_name][item_klass_name] =
                                    item_classes(ddata_set_name, item_klass_name)
                                end
                                acc
                              end
                            end
          elsif item_class_name.nil?
            item_classes(refresh: refresh)[data_set_name]
          elsif refresh
            item_classes(refresh: true)[data_set_name][item_class_name]
          else
            @item_classes[data_set_name] ||= {}
            @item_classes[data_set_name][item_class_name] ||=
              Paneron::Register::Raw::ItemClass.new(
                File.join(data_set_path(data_set_name), item_class_name),
                data_set: data_sets[data_set_name],
              )
          end
        end

        # @return Hash of { item_uuid => Item }
        #   - ["uuid"]
        def items(item_uuid = nil, refresh: false)
          @items = if !refresh && !@items.empty?
                     @items
                   else
                     data_sets(refresh: refresh).reduce({}) do |acc, (_ddata_set_name, data_set)|
                       data_set.items.each do |iitem_uuid, item|
                         acc[iitem_uuid] = item
                       end
                       acc
                     end
                   end

          if item_uuid.nil?
            @items
          else
            @items[item_uuid]
          end
        end

        def self.metadata_template
          {
            "title" => "",
            "datasets" => {
              # "data-set-1" => true,
            },
          }
        end

        private

        def log_change_git_remote(new_url)
          @old_git_url = @git_url
          @git_url = new_url
        end

        def change_git_remote(new_url, git_client: @git_client)
          if !git_client.remote(@git_remote_name).url.nil?
            git_client.remove_remote(@git_remote_name)
            if !new_url.nil?
              git_client.add_remote(@git_remote_name)
            end
          end
        end

        def git_url_changed?(url = @git_url)
          @old_git_url != url
        end

        def data_set_lutamls
          data_sets.map do |_data_set_name, data_set|
            data_set.to_lutaml
          end
        end

        # For abstraction
        class << self
          def clone_git_repo(git_url, repo_path)
            Git.clone(git_url, repo_path)
          end

          def open_git_repo(repo_path)
            Git.open(repo_path)
          end

          def init_git_repo(repo_path, initial_branch: nil)
            Git.init(repo_path, initial_branch: initial_branch)
          end
        end
      end
    end
  end
end
