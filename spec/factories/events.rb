# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    owner
    sequence(:name) { |i| "イベント名#{i}" }
    sequence(:place) { |i| "イベント開催場所#{i}" }
    sequence(:content) { |i| "イベント本文#{i}" }
    start_at { rand(1..30).days.from_now }
    end_at { start_at + rand(1..30).hours }

    trait :no_start_at do
      start_at { nil }
      end_at { Time.current + rand(1..30).hours }
    end
    trait :no_end_at do
      start_at { Time.current }
      end_at { nil }
    end
  end
end
