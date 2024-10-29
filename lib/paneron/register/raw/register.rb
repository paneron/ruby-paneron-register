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

        def get_metadata
          YAML.safe_load_file(register_yaml_path)
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

        def data_set_metadata_yaml(data_set_name)
          data_sets(data_set_name).get_metadata_yaml

          YAML.safe_load_file(
            data_set_yaml_path(data_set_name),
            permitted_classes: [Time],
          )
        end
      end
    end
  end
end
