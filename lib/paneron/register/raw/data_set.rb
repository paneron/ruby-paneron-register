# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class DataSet
        attr_reader :data_set_path, :data_set_root_path, :data_set_yaml_path,
                    :data_set_name

        def initialize(data_set_root_path, data_set_name)
          data_set_path = File.join(data_set_root_path, data_set_name)
          self.class.validate_data_set_path(data_set_path)
          @data_set_name = data_set_name
          @data_set_root_path = data_set_root_path
          @data_set_path = data_set_path
          @data_set_yaml_path = File.join(data_set_path,
                                          DATA_SET_METADATA_FILENAME)
          @item_classes = {}
          @item_class_names = nil
          @item_uuids = nil
        end

        DATA_SET_METADATA_FILENAME = "/register.yaml"

        def self.validate_data_set_path(data_set_path)
          unless File.exist?(data_set_path)
            raise Paneron::Register::Error,
                  "Data Set path does not exist"
          end
          unless File.directory?(data_set_path)
            raise Paneron::Register::Error,
                  "Data Set path is not a directory"
          end
          unless File.exist?(File.join(
                               data_set_path, DATA_SET_METADATA_FILENAME
                             ))
            raise Paneron::Register::Error,
                  "Data Set metadata file does not exist"
          end
        end

        def item_classes(item_class_name = nil)
          if item_class_name.nil?
            item_class_names.reduce({}) do |acc, item_class_name|
              acc[item_class_name] = item_classes(item_class_name)
              acc
            end
          else
            @item_classes[item_class_name] ||=
              Paneron::Register::Raw::ItemClass.new(
                data_set_root_path, data_set_name, item_class_name
              )
          end
        end

        def item_class_names
          @item_class_names ||=
            Dir.glob(File.join(data_set_path, "*/*.yaml"))
              .map { |file| File.basename(File.dirname(file)) }.uniq
        end

        def item_uuids
          item_classes.values.map(&:item_uuids).flatten
        end

        def get_metadata_yaml
          YAML.safe_load_file(
            data_set_yaml_path,
            permitted_classes: [Time],
          )
        end
      end
    end
  end
end
