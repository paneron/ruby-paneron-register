# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      attribute :name, Lutaml::Model::Type::String
      attribute :stakeholders, Paneron::Register::DataSetMetadata::Stakeholder,
                collection: true
      attribute :version, Paneron::Register::DataSetMetadata::Version
      attribute :contentSummary, Lutaml::Model::Type::String
      attribute :operatingLanguage, Paneron::Register::DataSetMetadata::OperatingLanguage
      attribute :organizations, Paneron::Register::DataSetMetadata::Organizations
    end
  end
end
