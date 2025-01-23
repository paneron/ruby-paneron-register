# frozen_string_literal: true

require "yaml"

module Paneron
  module Register
    module Raw
      class DataSet
        include Writeable
        include Validatable
        include RootFinder

        attr_reader :register_path,
                    :data_set_name, :extension
        attr_accessor :register

        def initialize(
          data_set_path = nil,
          extension = "yaml",
          register: nil
        )

          unless data_set_path.nil?
            register_path, new_data_set_name = Hierarchical.split_path(data_set_path)
          end

          # Deduce parent from self path,
          # if only self path is specified.
          @register = if register.nil?
                        Paneron::Register::Raw::Register.new(
                          register_path,
                        )
                      else
                        register
                      end

          if register_path != @register.register_path
            raise Paneron::Register::Error,
                  "Register path mismatch:\n" \
                  "Expected passed in register to align with data set's parent:\n" \
                  "#{@register.register_path} != #{register_path}"
          end

          @extension = extension
          @item_classes = {}
          @items = {}
          @metadata = nil
          @paneron_metadata = nil
          self.data_set_name = new_data_set_name
          @old_name = @data_set_name
          # {
          #   "title" => data_set_name,
          # }
        end

        DATA_SET_METADATA_FILENAME = "/register.yaml"
        PANERON_METADATA_FILENAME = "/panerondataset.yaml"

        def data_set_path
          File.join(register_path, data_set_name)
        end

        def data_set_name=(new_data_set_name)
          if new_data_set_name.nil? || new_data_set_name.empty?
            raise Paneron::Register::Error, "Data set name cannot be empty"
          end

          unless new_data_set_name.is_a?(String)
            raise Paneron::Register::Error, "Data set name must be a string"
          end

          @data_set_name = new_data_set_name
          self.title = new_data_set_name
        end

        def data_set_yaml_path
          File.join(data_set_path,
                    DATA_SET_METADATA_FILENAME)
        end

        def paneron_yaml_path
          File.join(data_set_path,
                    PANERON_METADATA_FILENAME)
        end

        def parent
          register
        end

        def self.name
          "Data set"
        end

        # Important that the parent paths are existent.
        def save_sequence
          # Save self
          require "fileutils"

          # Move old data set to new path
          old_path = File.join(register_path, @old_name)
          if File.directory?(old_path) && @old_name != data_set_name
            FileUtils.mv(old_path, self_path)
            @old_name = data_set_name
          else
            FileUtils.mkdir_p(self_path)
          end

          # TODO: populate template with sensible defaults
          if @metadata.nil? || @metadata.empty?
            File.write(data_set_yaml_path, self.class.metadata_template.to_yaml)
          else
            File.write(data_set_yaml_path, metadata.to_yaml)
          end

          # TODO: populate template with sensible defaults
          if @paneron_metadata.nil? || @paneron_metadata.empty?
            File.write(paneron_yaml_path,
                       self.class.paneron_metadata_template(data_set_name).to_yaml)
          else
            File.write(paneron_yaml_path, paneron_metadata.to_yaml)
          end

          # Save item classes
          item_class_names.each do |item_class_name|
            new_thing = item_classes(item_class_name)
            new_thing.data_set = self
            new_thing.save
          end

          # # Save proposals
          # proposal_uuids.each do |proposal_uuid|
          #   proposals(proposal_uuid).save
          # end
        end

        def self_path
          data_set_path
        end

        def is_valid?
          self.data_set_name = data_set_name
          register.valid?
        end

        def set_register(new_register)
          @register = new_register
        end

        def register_path
          @register.register_path
        end

        def add_item_classes(*new_item_classes)
          new_item_classes = [new_item_classes] unless new_item_classes.is_a?(Enumerable)
          new_item_classes.each do |item_class|
            item_class.set_data_set(self)
            @item_classes[item_class.item_class_name] = item_class
          end
        end

        def self.validate_path_before_saving
          true
        end

        def self.validate_path(path)
          unless File.exist?(path)
            raise Paneron::Register::Error,
                  "#{name} path (#{path}) does not exist"
          end

          unless File.directory?(path)
            raise Paneron::Register::Error,
                  "#{name} path (#{path}) is not a directory"
          end

          data_set_file = File.join(
            path, DATA_SET_METADATA_FILENAME
          )
          unless File.exist?(data_set_file)
            raise Paneron::Register::Error,
                  "Data Set metadata file (#{data_set_file}) does not exist"
          end
        end

        def to_lutaml
          Paneron::Register::DataSet.new(
            name: data_set_name,
            item_classes: item_class_lutamls,
            metadata: metadata_lutaml,
            paneron_metadata: paneron_metadata_lutaml,
          )
        end

        def item_class_lutamls
          item_classes.map do |_item_class_name, item_class|
            item_class.to_lutaml
          end
        end

        def item_classes(item_class_name = nil, refresh: false)
          if item_class_name.nil?
            @item_classes = if !refresh && !@item_classes.empty?
                              @item_classes
                            else
                              item_class_names(refresh: refresh).reduce({}) do |acc, item_class_name|
                                acc[item_class_name] = item_classes(item_class_name)
                                acc
                              end
                            end
          elsif refresh
            item_classes[item_class_name]
          else
            @item_classes[item_class_name] ||=
              Paneron::Register::Raw::ItemClass.new(
                File.join(data_set_path, item_class_name),
                data_set: self,
              )
          end
        end

        def spawn_item_class(item_class_name, metadata: {})
          new_item_class = Paneron::Register::Raw::ItemClass.new(
            File.join(data_set_path, item_class_name),
            data_set: self,
          )

          add_item_classes(new_item_class)

          new_item_class
        end

        def item_class_names(refresh: false)
          if refresh || @item_classes.empty?
            Dir.glob(File.join(data_set_path, "*/*.#{extension}"))
              .map { |file| File.basename(File.dirname(file)) }.to_set
          else
            @item_classes.keys
          end
        end

        def item_uuids
          item_classes.values.map(&:item_uuids).to_set.flatten
        end

        def items(uuid = nil, item_class_name = nil, refresh: false)
          if uuid.nil?
            @items = if !refresh && !@items.empty?
                       @items
                     else
                       item_classes.reduce({}) do |acc, (item_klass_name, item_klass)|
                         item_klass.item_uuids.each do |item_uuid|
                           acc[item_uuid] = items(item_uuid, item_klass_name)
                         end
                         acc
                       end
                     end
          elsif refresh
            items[uuid]
          else
            @items[uuid] ||=
              Paneron::Register::Raw::Item.new(
                uuid,
                File.join(data_set_path, item_class_name),
                item_class: item_classes[item_class_name],
              )
          end
        end

        # TODO: Add validation to register.yaml fields
        # name: Full Name of Data Set
        # stakeholders: [ { roles, name, gitServerUsername, affiliations, contacts } ]
        # version: { id, timestamp }
        # contentSummary:
        # operatingLanguage: { name, country, language }
        # organizations: { uuid..: { name, logoURL } }
        # TODO: Add support to read/write panerondataset.yaml
        # title: short-name
        #   type:
        #     id: 'npm-paneron-extension-name'
        #     version: 0.0.1-alpha1
        def paneron_metadata
          @paneron_metadata ||= begin
            YAML.safe_load_file(
              paneron_yaml_path,
              permitted_classes: [Time, Date, DateTime],
            )
          rescue Errno::ENOENT
            {}
          end
        end

        def merge_paneron_metadata(other)
          paneron_metadata.merge!(other)
        end

        def paneron_metadata=(new_paneron_metadata)
          @paneron_metadata = new_paneron_metadata
        end

        def paneron_metadata_lutaml
          Paneron::Register::PaneronMetadata.new(
            paneron_metadata,
          )
        end

        def metadata
          @metadata ||= begin
            YAML.safe_load_file(
              data_set_yaml_path,
              permitted_classes: [Time, Date, DateTime],
            )
          rescue Errno::ENOENT
            {}
          end
        end

        def metadata_lutaml
          Paneron::Register::DataSetMetadata.new(
            metadata,
          )
        end

        def merge_metadata(other)
          metadata.merge!(other)
        end

        def metadata=(metadata)
          @metadata = metadata
        end

        def name=(new_name)
          metadata["name"] = new_name.to_s
        end

        # This is really just data_set_name
        def title=(new_title)
          paneron_metadata["title"] = new_title.to_s
        end
        private :title=

        def title
          paneron_metadata["title"]
        end

        def stakeholders
          metadata["stakeholders"] || []
        end

        def stakeholders=(new_stakeholders)
          metadata["stakeholders"] ||= new_stakeholders
        end

        def content_summary
          metadata["contentSummary"] || ""
        end

        def content_summary=(new_content_summary)
          metadata["contentSummary"] = new_content_summary.to_s
        end

        def operating_language
          metadata["operatingLanguage"] || {}
        end

        def operating_language=(name: "", country: "", language: "")
          metadata["operatingLanguage"] = {
            "name" => name.to_s,
            "country" => country.to_s,
            "language" => language.to_s,
          }
        end

        def organizations
          metadata["organizations"] || {}
        end

        def organizations=(new_organizations)
          metadata["organizations"] = case new_organizations
                                      when Hash then new_organizations
                                      else
                                        raise Paneron::Register::Error, "organizations must be a hash"
                                      end
        end

        def self.metadata_template
          {
            "name" => "",
            "stakeholders" => [
              # {
              #   "roles" => [],
              #   "name" => "",
              #   "gitServerUsername" => "",
              #   "affiliations" => [],
              #   "contacts" => [],
              # },
            ],
            "version" => nil, # { "id" => "", "timestamp" => "" },
            "contentSummary" => "",
            "operatingLanguage" => {
              "name" => "English",
              "country" => "N/A",
              "language" => "eng",
            },
            "organizations" => {
              # "uuid" => { "name" => "", "logoURL" => "" },
            },
          }
        end

        def self.paneron_metadata_template(title: "")
          {
            "title" => "",
            "type" => {
              "id" => "",
              "version" => "",
            },
          }
        end
      end
    end
  end
end
