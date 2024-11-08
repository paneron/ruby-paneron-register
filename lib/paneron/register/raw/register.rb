# frozen_string_literal: true

require "yaml"
require "set"

module Paneron
  module Register
    module Raw
      class Register
        include Writeable
        include Validatable

        attr_reader :git_client, :git_url
        attr_accessor :register_path

        def initialize(
          register_path,
          git_url: nil,
          git_client: nil
        )
          @git_url = git_url
          @git_client = git_client

          @register_path = register_path
          @old_path = @register_path
          @data_sets = {}
          @metadata = nil
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
              Dir.exist?(ENV["XDG_CACHE_HOME"]) ? ENV["XDG_CACHE_HOME"] : "~/.cache",
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
        def self.generate(register_path, git_url: nil)
          new(register_path, git_url: git_url).save
        end

        def self.from_git(repo_url, update: true)
          require "git"
          setup_cache_path
          repo_cache_name =
            "#{File.basename(repo_url)}-#{calculate_repo_cache_hash(repo_url)}"

          # Check if repo is already cloned
          full_local_cache_path = File.join(local_cache_path, repo_cache_name)
          g = begin
            if File.exist?(full_local_cache_path)
              _g = Git.open(full_local_cache_path)

              # Pull-rebase to update it
              if update
                _g.pull(
                  nil, nil, rebase: true
                )
              end
              _g
            else
              Git.clone(
                repo_url,
                repo_cache_name,
                path: local_cache_path,
                # timeout: 30,
              )
            end
          rescue Git::TimeoutError => e
            e.result.tap do |_r|
              warn "Timed out trying to clone #{repo_url}."
              raise e
            end
          end

          new(g.dir.path, git_url: repo_url, git_client: g)
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

        def data_set_names
          if @data_sets.empty?
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

        def data_sets(data_set_name = nil)
          if data_set_name.nil?
            @data_sets = if !@data_sets.empty?
                           @data_sets
                         else
                           data_set_names.reduce({}) do |acc, data_set_name|
                             acc[data_set_name] = data_sets(data_set_name)
                             acc
                           end
                         end
          else
            @data_sets[data_set_name] ||=
              Paneron::Register::Raw::DataSet.new(
                File.join(register_path, data_set_name),
                register: self,
              )
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

        def data_set_lutamls
          data_sets.map do |_data_set_name, data_set|
            data_set.to_lutaml
          end
        end
      end
    end
  end
end
