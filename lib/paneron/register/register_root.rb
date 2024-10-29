# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    class RegisterRoot
      attr_reader :register_root_path, :register_root_yaml_path

      def initialize(register_root_path)
        self.class.validate_root_path(register_root_path)
        @register_root_path = register_root_path
        @register_root_yaml_path = File.join(register_root_path,
                                             REGISTER_ROOT_METADATA_FILENAME)
        @register_names = nil
        @registries = {}
      end

      REGISTER_ROOT_METADATA_FILENAME = "/paneron.yaml".freeze

      def self.validate_root_path(register_root_path)
        unless File.exist?(register_root_path)
          raise Paneron::Register::Error,
                "Register root path does not exist"
        end
        unless File.directory?(register_root_path)
          raise Paneron::Register::Error,
                "Register root path is not a directory"
        end
        unless File.exist?(File.join(
                             register_root_path, REGISTER_ROOT_METADATA_FILENAME
                           ))
          raise Paneron::Register::Error,
                "Register root metadata file does not exist"
        end
      end

      def register_names
        @register_names ||= Dir.glob(
          File.join(
            register_root_path,
            "*#{Paneron::Register::Register::REGISTER_METADATA_FILENAME}",
          ),
        )
          .map do |file|
            File.basename(File.dirname(file))
          end
      end

      def register_path(register_name)
        File.join(register_root_path, register_name)
      end

      def get_root_metadata
        YAML.safe_load_file(register_root_yaml_path)
      end

      def registries(register_name = nil)
        if register_name.nil?
          register_names.reduce({}) do |acc, register_name|
            acc[register_name] = registries(register_name)
            acc
          end
        else
          @registries[register_name] ||=
            Paneron::Register::Register.new(register_root_path,
                                            register_name)
        end
      end

      def register_metadata_yaml(register_name)
        registires(register_name).get_metadata_yaml

        YAML.safe_load_file(
          register_yaml_path(register_name),
          permitted_classes: [Time],
        )
      end
    end
  end
end
