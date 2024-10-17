require "yaml"

module Paneron
  module Register
    class Register
      attr_reader :register_path, :register_root_path, :register_yaml_path,
                  :register_name

      def initialize(register_root_path, register_name)
        register_path = File.join(register_root_path, register_name)
        self.class.validate_register_path(register_path)
        @register_name = register_name
        @register_root_path = register_root_path
        @register_path = register_path
        @register_yaml_path = File.join(register_path,
                                        REGISTER_METADATA_FILENAME)
        @item_classes = {}
        @item_class_names = nil
        @item_uuids = nil
      end

      REGISTER_METADATA_FILENAME = "/register.yaml".freeze

      def self.validate_register_path(register_path)
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

      def item_classes(item_class_name = nil)
        if item_class_name.nil?
          item_class_names.reduce({}) do |acc, item_class_name|
            acc[item_class_name] = item_classes(item_class_name)
            acc
          end
        else
          @item_classes[item_class_name] ||=
            Paneron::Register::ItemClass.new(
              register_root_path, register_name, item_class_name
            )
        end
      end

      def item_class_names
        @item_class_names ||=
          Dir.glob(File.join(register_path, "*/*.yaml"))
            .map { |file| File.basename(File.dirname(file)) }.uniq
      end

      def item_uuids
        item_classes.values.map(&:item_uuids).flatten
      end

      def get_metadata_yaml
        YAML.safe_load_file(
          register_yaml_path,
          permitted_classes: [Time],
        )
      end
    end
  end
end
