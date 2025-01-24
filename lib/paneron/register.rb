# frozen_string_literal: true

require "paneron/register/version"
require "paneron/register/error"

require "paneron/register/writeable"
require "paneron/register/validatable"
require "paneron/register/hierarchical"
require "paneron/register/root_finder"

require "paneron/register/type/js_date_iso_string"

require "paneron/register/raw/item"
require "paneron/register/raw/item_class"
require "paneron/register/raw/data_set"
require "paneron/register/raw/register"

require "paneron/register/proposal_state"
require "paneron/register/proposal_states"
require "paneron/register/item_status"
require "paneron/register/item_statuses"
require "paneron/register/item"
require "paneron/register/item_class"

require "paneron/register/paneron_metadata/data_set_type"
require "paneron/register/paneron_metadata"
require "paneron/register/data_set_metadata/organization"
require "paneron/register/data_set_metadata/organizations"
require "paneron/register/data_set_metadata/affiliation"
require "paneron/register/data_set_metadata/affiliations"
require "paneron/register/data_set_metadata/contact"
require "paneron/register/data_set_metadata/stakeholder"
require "paneron/register/data_set_metadata/version"
require "paneron/register/data_set_metadata/operating_language"
require "paneron/register/data_set_metadata"

require "paneron/register/data_set"
require "paneron/register/register_metadata/dataset"
require "paneron/register/register_metadata/datasets"
require "paneron/register/register_metadata"
require "paneron/register/register"

# Paneron::Register module
module Paneron
  module Register; end
end
