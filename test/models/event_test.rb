# frozen_string_literal: true

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test '#created_by? owner_id と引数の#idが同じ時' do
    event = create(:event)
    user = MiniTest::Mock.new.expect(:id, event.owner_id)
    assert_equal(true, event.created_by?(user))
    user.verify
  end
  test '#created_by? owner_id と引数の#idが異なる時' do
    event = create(:event)
    another_user = create(:user)
    assert_equal(false, event.created_by?(another_user))
  end
  test '#created_by? 引数が nilな時' do
    event = create(:event)
    assert_equal(false, event.created_by?(nil))
  end

  test 'start_at_should_be_before_end_at validation OK' do
    start_at = rand(1..30).days.from_now
    end_at = start_at + rand(1..30).hours
    event = build(:event, start_at:, end_at:)
    event.valid?
    assert_empty(event.errors[:start_at])
  end

  test 'start_at_should_be_before_end_at validation error' do
    start_at = rand(1..30).days.from_now
    end_at = start_at - rand(1..30).hours
    event = build(:event, start_at:, end_at:)
    event.valid?
    assert_not_empty(event.errors[:start_at])
  end
end
