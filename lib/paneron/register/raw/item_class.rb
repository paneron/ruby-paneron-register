# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class ItemClass
        attr_reader :data_set_path,
                    :item_class_name, :item_class_path, :extension

        def initialize(
          data_set_path,
          item_class_name,
          extension = "yaml"
        )
          item_class_path = File.join(data_set_path, item_class_name)
          self.class.validate_item_class_path(item_class_path)
          @extension = extension
          @data_set_path = data_set_path
          @item_class_name = item_class_name
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

        def to_lutaml
          Paneron::Register::ItemClass.new(
            name: item_class_name,
            items: item_lutamls,
          )
        end

        def item_uuids
          @item_uuids ||= Dir.glob(File.join(item_class_path, "*.#{extension}"))
            .map { |file| File.basename(file, ".#{extension}") }
        end

        def items(uuid = nil)
          if uuid.nil?
            item_uuids.reduce({}) do |acc, uuid|
              acc[uuid] = items(uuid)
              acc
            end
          else
            @items[uuid] ||=
              Paneron::Register::Raw::Item.new(
                item_class_path, uuid
              )
          end
        end

        def item_lutamls
          items.values.map(&:to_lutaml)
        end
      end
    end
  end
end
