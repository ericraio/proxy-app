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
    if host_changed?
      change = host_change[1]
      PrefetchSslJob.set(wait: 10.seconds).perform_later(change) if change
    end
  end
end
