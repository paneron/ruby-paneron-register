# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class Register
        attr_reader :register_path, :register_yaml_path

        def initialize(register_path)
          self.class.validate_path(register_path)
          @register_path = register_path
          @register_yaml_path = File.join(register_path,
                                          REGISTER_METADATA_FILENAME)
          @data_set_names = nil
          @data_sets = {}
          @metadata = nil
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

          new(g.dir.path)
        end

        REGISTER_METADATA_FILENAME = "/paneron.yaml"

        def self.validate_path(register_path)
          unless File.exist?(register_path)
            raise Paneron::Register::Error,
                  "Register path does not exist"
          end
          unless File.directory?(register_path)
            raise Paneron::Register::Error,
                  "Register path is not a directory"
          end
          unless File.exist?(File.join(
                               register_path, REGISTER_METADATA_FILENAME
                             ))
            raise Paneron::Register::Error,
                  "Register metadata file does not exist"
          end
        end

        def to_lutaml
          Paneron::Register::Register.new(
            data_sets: data_set_lutamls,
            metadata: metadata.to_json,
          )
        end

        def data_set_names
          @data_set_names ||= Dir.glob(
            File.join(
              register_path,
              "*#{Paneron::Register::Raw::DataSet::DATA_SET_METADATA_FILENAME}",
            ),
          )
            .map do |file|
              File.basename(File.dirname(file))
            end
        end

        def data_set_path(data_set_name)
          File.join(register_path, data_set_name)
        end

        def metadata
          @metadata ||= YAML.safe_load_file(register_yaml_path)
        end

        def data_sets(data_set_name = nil)
          if data_set_name.nil?
            data_set_names.reduce({}) do |acc, data_set_name|
              acc[data_set_name] = data_sets(data_set_name)
              acc
            end
          else
            @data_sets[data_set_name] ||=
              Paneron::Register::Raw::DataSet.new(register_path,
                                                  data_set_name)
          end
        end

        def data_set_lutamls
          data_sets.map do |_data_set_name, data_set|
            data_set.to_lutaml
          end
        end
      end
    end
  end
end
