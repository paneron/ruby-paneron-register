# frozen_string_literal: true

module Paneron
  module Register
    # From registry-kit
    ITEM_STATUSES = {
      INVALID: "invalid",
      RETIRED: "retired",
      SUBMITTED: "submitted",
      SUPERSEDED: "superseded",
      VALID: "valid",
    }
      .transform_values { |v| Paneron::Register::ItemStatus.new(state: v) }
      .freeze
  end
end
