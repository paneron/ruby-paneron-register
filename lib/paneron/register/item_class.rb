# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class ItemClass < Lutaml::Model::Serializable
      attribute :name, Lutaml::Model::Type::String
      attribute :items, Paneron::Register::Item, collection: true
    end
  end
end
