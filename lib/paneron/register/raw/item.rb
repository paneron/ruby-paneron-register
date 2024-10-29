# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class Item
        attr_reader :item_class_path,
                    :item_id,
                    :item_path,
                    :extension

        def initialize(
          item_class_path,
          item_id,
          extension = "yaml"
        )
          item_path = File.join(item_class_path, "#{item_id}.#{extension}")
          self.class.validate_item_path(item_path)
          @item_class_path = item_class_path
          @item_id = item_id
          @item_path = item_path
          @extension = extension
          @to_h = nil
        end

        def self.validate_item_path(path)
          unless File.exist?(path)
            raise Paneron::Register::Error,
                  "Item path does not exist"
          end
          unless File.file?(path)
            raise Paneron::Register::Error,
                  "Item path is not a file"
          end
        end

        def to_lutaml
          Paneron::Register::Item.new(
            id: item_id,
            data: to_h["data"],
            status: Paneron::Register::ItemStatus.new(state: to_h["status"]),
            date_accepted: to_h["dateAccepted"].to_s,
          )
        end

        def to_h
          @to_h ||=
            YAML.safe_load_file(
              File.join(item_path),
              permitted_classes: [Time],
            )
        end
      end
    end
  end
end
