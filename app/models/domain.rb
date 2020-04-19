# frozen_string_literal: true

##
#
# Domain.
#
# The model responsible validating the data and interacting to
# the database table at domains.
#
class Domain < ApplicationRecord
  validates :host, :origin, presence: true
end
