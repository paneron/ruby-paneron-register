# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class ProposalState < Lutaml::Model::Serializable
      attribute :state, :string
    end
  end
end
