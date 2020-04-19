# frozen_string_literal: true

FactoryBot.define do
  factory :domain do
    host { 'host.com' }
    origin { 'origin.com' }
    verified { true }
  end
end
