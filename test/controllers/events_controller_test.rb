# frozen_string_literal: true

require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  test '自分でつくったイベントは削除できる' do
    event_owner = create(:user)
    event = create(:event, owner: event_owner)
    sign_in_as event_owner
    assert_difference('Event.count', -1) do
      delete event_url(event)
    end
  end
end
