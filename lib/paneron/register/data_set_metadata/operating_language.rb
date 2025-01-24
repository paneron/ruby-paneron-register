# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class OperatingLanguage < Lutaml::Model::Serializable
        attribute :name, Lutaml::Model::Type::String, default: -> { "English" }
        attribute :country, Lutaml::Model::Type::String, default: -> { "N/A" }
        attribute :languageCode, Lutaml::Model::Type::String, default: -> { "eng" }
      end
    end
  end
end
