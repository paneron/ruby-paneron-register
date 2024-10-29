# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class ItemClass
        attr_reader :register_path, :register_root_path, :register_yaml_path,
                    :item_class_name, :item_class_path, :register_name

        def initialize(register_root_path, register_name, item_class_name)
          File.join(register_root_path, register_name)
          item_class_path = File.join(register_root_path, register_name,
                                      item_class_name)
          self.class.validate_item_class_path(item_class_path)
          @item_class_path = item_class_path
          @items_uuids = nil
          @items = {}
        end

        def self.validate_item_class_path(path)
          unless File.exist?(path)
            raise Paneron::Register::Error,
                  "Item class path does not exist"
          end
          unless File.directory?(path)
            raise Paneron::Register::Error,
                  "Item class path is not a directory"
          end
        end

        def item_uuids
          @item_uuids ||= Dir.glob(File.join(item_class_path, "*.yaml"))
            .map { |file| File.basename(file, ".yaml") }
        end

        def item_yamls(uuid = nil)
          if uuid.nil?
            item_uuids.reduce({}) do |acc, uuid|
              acc[uuid] = item_yamls(uuid)
              acc
            end
          else
            @items[uuid] ||=
              YAML.safe_load_file(
                File.join(item_class_path, "#{uuid}.yaml"),
                permitted_classes: [Time],
              )
          end
        end
      end
    end
  end
end
