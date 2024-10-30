# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class Item
        include Writeable
        include Validatable
        include RootFinder

        attr_reader :item_id,
                    :extension
        attr_accessor :item_class

        def initialize(
          item_id,
          item_class_path = nil,
          extension = "yaml",
          item_class: nil
        )
          # Deduce parent from self path,
          # if only self path is specified.
          @item_class = if item_class.nil?
                          Paneron::Register::Raw::ItemClass.new(
                            item_class_path,
                          )
                        else
                          item_class
                        end

          @item_id = item_id
          @extension = extension
          @to_h = nil
          @status = nil
          @data = nil
          @date_accepted = nil
        end

        def item_path
          File.join(item_class_path, "#{item_id}.#{extension}")
        end

        def item_class_path
          @item_class.item_class_path
        end

        def set(
          status: nil,
          data: nil,
          date_accepted: nil
        )
          self.status = status
          self.data = data
          self.date_accepted = date_accepted
        end

        def id
          @item_id
        end

        def status
          @status ||= disk_to_h["status"]
        end

        def status=(new_status)
          @status = new_status
        end

        def data
          @data ||= disk_to_h["data"]
        end

        def data=(new_data)
          @data = new_data
        end

        def date_accepted
          @date_accepted ||= disk_to_h["dateAccepted"]
        end

        def date_accepted=(new_date_accepted)
          @date_accepted = case new_date_accepted
                           when String then DateTime.parse(new_date_accepted)
                           when DateTime then new_date_accepted
                           when Time, Date then new_date_accepted.to_datetime
                           when NilClass then nil
                           else
                             raise Paneron::Register::Error,
                                   "Invalid date: #{new_date_accepted}"
                           end
        end

        def parent
          item_class
        end

        def self.name
          "Item"
        end

        def save_sequence
          # Save self
          require "fileutils"
          FileUtils.mkdir_p(item_class_path)

          File.write(item_path, to_h.to_yaml)
        end

        def self_path
          item_path
        end

        def is_valid?
          item_class.valid?
        end

        def set_item_class(new_item_class)
          @item_class = new_item_class
        end

        def self.validate_path_before_saving
          true
        end

        def self.validate_path(path)
          unless File.exist?(path)
            raise Paneron::Register::Error,
                  "Item path (#{path}) does not exist"
          end
          unless File.file?(path)
            raise Paneron::Register::Error,
                  "Item path (#{path}) is not a file"
          end
        end

        def to_lutaml
          Paneron::Register::Item.new(
            id: item_id,
            data: data,
            status: Paneron::Register::ItemStatus.new(state: status),
            date_accepted: date_accepted.to_s,
          )
        end

        def to_h
          {
            "id" => item_id,
            "data" => data,
            "status" => status,
            "dateAccepted" => date_accepted,
          }
        end

        def disk_to_h
          @disk_to_h ||=
            YAML.safe_load_file(
              File.join(item_path),
              permitted_classes: [Time, Date, DateTime],
            )
        end
      end
    end
  end
end