# frozen_string_literal: true

require "lutaml/model"

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
        # NOTE: There is no { optional: true } # Use render_nil: true for all other attributes in the render block instead
        attribute :notes, Lutaml::Model::Type::String
        attribute :contacts, Paneron::Register::DataSetMetadata::Contact,
                  collection: true
      end
    end
  end
end
