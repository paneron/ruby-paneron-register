# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class Item < Lutaml::Model::Serializable
      # 'id' is a UUID
      attribute :id, Lutaml::Model::Type::String

      # TODO: data is free form object
      attribute :data, Lutaml::Model::Type::String
      attribute :status, Paneron::Register::ItemStatus, values:
        Paneron::Register::ITEM_STATUSES.values
      attribute :date_accepted, Lutaml::Model::Type::DateTime
    end
  end
end
