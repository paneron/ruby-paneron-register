# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class Proposal < Lutaml::Model::Serializable
      attribute :uuid, Lutaml::Model::Type::String
      attribute :date_accepted, Lutaml::Model::Type::DateTime
      attribute :state, Paneron::Register::ProposalState, values:
        Paneron::Register::PROPOSAL_STATES.values
    end
  end
end
