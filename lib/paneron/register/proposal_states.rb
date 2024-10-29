# frozen_string_literal: true

module Paneron
  module Register
    PROPOSAL_STATES = {
      ACCEPTED: Paneron::Register::ProposalState.new("accepted"),
      REJECTED: Paneron::Register::ProposalState.new("rejected"),
      WITHDRAWN: Paneron::Register::ProposalState.new("withdrawn"),
    }.freeze
  end
end
