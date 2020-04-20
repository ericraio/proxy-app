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

  before_save do
    PrefetchSslJob.set(wait: 10.seconds).perform_later(origin_change[0]) if origin_changed?
  end
end
