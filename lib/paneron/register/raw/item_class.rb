# frozen_string_literal: true

module Paneron
  module Register
    module Raw
      class ItemClass
        include Writeable
        include Validatable
        include RootFinder

        attr_reader :item_class_name, :extension

        attr_accessor :data_set

        def initialize(
          item_class_path = nil,
          extension = "yaml",
          data_set: nil
        )

          unless item_class_path.nil?
            data_set_path, item_class_name = Hierarchical.split_path(item_class_path)
          end

          # Deduce parent from self path,
          # if only self path is specified.
          @data_set = if data_set.nil?
                        Paneron::Register::Raw::DataSet.new(
                          data_set_path,
                        )
                      else
                        data_set
                      end

          @item_class_name = item_class_name
          @old_name = @item_class_name
          @items_uuids = nil
          @items = {}
          @extension = extension
        end

        def item_class_path
          File.join(data_set_path, item_class_name)
        end

        def item_class_name=(new_item_class_name)
          if new_item_class_name.nil? || new_item_class_name.empty?
            raise Paneron::Register::Error, "Item class name cannot be empty"
          end

          unless new_item_class_name.is_a?(String)
            raise Paneron::Register::Error, "Item class name must be a string"
          end

          @item_class_name = new_item_class_name
        end

        def parent
          data_set
        end

        def self.name
          "Item class"
        end

        def save_sequence
          # Save self
          require "fileutils"

          # Move old data set to new path
          old_path = File.join(data_set_path, @old_name)
          if File.directory?(old_path) && @old_name != item_class_name
            FileUtils.mv(old_path, self_path)
            @old_name = item_class_name
          else
            FileUtils.mkdir_p(self_path)
          end

          # Save items
          item_uuids.each do |item_uuid|
            items(item_uuid).save
          end
        end

        def self_path
          item_class_path
        end

        def is_valid?
          data_set.valid?
        end

        def set_data_set(new_data_set)
          @data_set = new_data_set
        end

        def data_set_path
          data_set.data_set_path
        end

        def add_items(new_items)
          new_items = [new_items] unless new_items.is_a?(Enumerable)
          new_items.each do |item|
            item.set_item_class(self)
            @items[item.id] = item
            item_uuids << item.id
          end
        end

        def self.validate_path_before_saving
          true
        end

        def self.validate_path(path)
          unless File.exist?(path)
            raise Paneron::Register::Error,
                  "Item class path (#{path}) does not exist"
          end
          unless File.directory?(path)
            raise Paneron::Register::Error,
                  "Item class path (#{path}) is not a directory"
          end
        end

        def to_lutaml
          Paneron::Register::ItemClass.new(
            name: item_class_name,
            items: item_lutamls,
          )
        end

        def spawn_item(item_uuid)
          new_item =
            @items[item_uuid] =
              Paneron::Register::Raw::Item.new(
                item_uuid,
                item_class: self,
              )

          item_uuids << item_uuid
          new_item
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
                uuid,
                item_class_path,
                item_class: self,
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
