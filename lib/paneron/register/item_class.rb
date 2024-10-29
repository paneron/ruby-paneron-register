# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class ItemClass < Lutaml::Model::Serializable
      attribute :uuid, Lutaml::Model::Type::String
    end
  end
end