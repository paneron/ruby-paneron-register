require "yaml"

module PaneronRegistry
  class Registry
    attr_reader :registry_path, :registry_root_path, :registry_yaml_path,
                :registry_name

    def initialize(registry_root_path, registry_name)
      registry_path = File.join(registry_root_path, registry_name)
      self.class.validate_registry_path(registry_path)
      @registry_name = registry_name
      @registry_root_path = registry_root_path
      @registry_path = registry_path
      @registry_yaml_path = File.join(registry_path,
                                      REGISTER_METADATA_FILENAME)
      @item_classes = {}
      @item_class_names = nil
      @item_uuids = nil
    end

    REGISTER_METADATA_FILENAME = "/register.yaml".freeze

    def self.validate_registry_path(registry_path)
      unless File.exist?(registry_path)
        raise PaneronRegistry::Error,
              "Registry path does not exist"
      end
      unless File.directory?(registry_path)
        raise PaneronRegistry::Error,
              "Registry path is not a directory"
      end
      unless File.exist?(File.join(
                           registry_path, REGISTER_METADATA_FILENAME
                         ))
        raise PaneronRegistry::Error,
              "Registry metadata file does not exist"
      end
    end

    def item_classes(item_class_name = nil)
      if item_class_name.nil?
        item_class_names.map do |item_class_name|
          item_classes(item_class_name)
        end
      else
        @item_classes[item_class_name] ||=
          PaneronRegistry::ItemClass.new(
            registry_root_path, registry_name, item_class_name
          )
      end
    end

    def item_class_names
      @item_class_names ||=
        Dir.glob(File.join(registry_path, "*/*.yaml"))
          .map { |file| File.basename(File.dirname(file)) }.uniq
    end

    def item_uuids
      item_classes.map(&:item_uuids).flatten
    end

    def get_metadata_yaml
      YAML.safe_load_file(
        registry_yaml_path,
        permitted_classes: [Time],
      )
    end
  end
end
