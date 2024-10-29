# frozen_string_literal: true

module Paneron
  module Register
    # From registry-kit
    PROPOSAL_STATES = {
      DRAFT: "draft",
      PROPOSED: "proposed",
      SUBMITTED_FOR_CONTROL_BODY_REVIEW: "pending-control-body-review",
      RETURNED_FOR_CLARIFICATION: "returned-for-clarification",
      ACCEPTED: "accepted",
      REJECTED: "rejected",
      APPEALED: "rejection-appealed-to-owner",
      WITHDRAWN: "withdrawn",
      ACCEPTED_ON_APPEAL: "accepted-on-appeal",
      REJECTION_UPHELD_ON_APPEAL: "rejection-upheld-on-appeal",
      APPEAL_WITHDRAWN: "appeal-withdrawn",
    }
      .transform_values { |v| Paneron::Register::ProposalState.new(state: v) }
      .freeze
  end
end
