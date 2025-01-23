# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Contact < Lutaml::Model::Serializable
        attribute :label, Lutaml::Model::Type::String, default: -> { "email" }
        attribute :value, Lutaml::Model::Type::String
        attribute :notes, Lutaml::Model::Type::String # NOTE: There is no { optional: true } # Use render_nil: true for all other attributes in the render block instead
      end
    end
  end
end
