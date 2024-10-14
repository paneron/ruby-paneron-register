require "yaml"

module PaneronRegistry
  class RegistryRoot
    attr_reader :registry_root_path, :registries, :registry_root_yaml_path

    def initialize(registry_root_path)
      self.class.validate_root_path(registry_root_path)
      @registry_root_path = registry_root_path
      @registry_root_yaml_path = File.join(registry_root_path,
                                           REGISTER_ROOT_METADATA_FILENAME)
      @registries = {}
    end

    REGISTER_ROOT_METADATA_FILENAME = "/paneron.yaml".freeze

    def self.validate_root_path(registry_root_path)
      unless File.exist?(registry_root_path)
        raise PaneronRegistry::Error,
              "Registry root path does not exist"
      end
      unless File.directory?(registry_root_path)
        raise PaneronRegistry::Error,
              "Registry root path is not a directory"
      end
      unless File.exist?(File.join(
                           registry_root_path, REGISTER_ROOT_METADATA_FILENAME
                         ))
        raise PaneronRegistry::Error,
              "Registry root metadata file does not exist"
      end
    end

    def list_registries
      Dir.glob(
        File.join(
          registry_root_path,
          "*#{PaneronRegistry::Registry::REGISTER_METADATA_FILENAME}",
        ),
      )
        .map do |file|
        File.basename(File.dirname(file))
      end
    end

    def registry_path(registry_name)
      File.join(registry_root_path, registry_name)
    end

    def get_root_metadata
      YAML.safe_load_file(registry_root_yaml_path)
    end

    def get_registry(registry_name)
      @registries[registry_name] ||=
        PaneronRegistry::Registry.new(registry_root_path,
                                      registry_name)
    end

    def get_registry_metadata_yaml(registry_name)
      get_registry(registry_name).get_metadata_yaml

      YAML.safe_load_file(
        registry_yaml_path(registry_name),
        permitted_classes: [Time],
      )
    end
  end
end
