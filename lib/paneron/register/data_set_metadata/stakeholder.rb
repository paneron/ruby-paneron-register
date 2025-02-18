# frozen_string_literal: true

require "lutaml/model"

# NOTE: All attributes in a LutaML model are optional by default.
module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Stakeholder < Lutaml::Model::Serializable
        attribute :name, Lutaml::Model::Type::String
        attribute :roles, Lutaml::Model::Type::String,
                  collection: true,
                  values: %w[
                    owner
                    control-body
                    control-body-reviewer
                    manager
                    submitter
                  ]
        attribute :gitServerUsername, Lutaml::Model::Type::String
        attribute :affiliations, Paneron::Register::DataSetMetadata::Affiliations
        attribute :notes, Lutaml::Model::Type::String
        attribute :contacts, Paneron::Register::DataSetMetadata::Contact,
                  collection: true
      end
    end
  end
end
