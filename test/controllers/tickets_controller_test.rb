# frozen_string_literal: true

require 'test_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = tickets(:one)
  end

  test 'should get index' do
    get tickets_url, as: :json
    assert_response :success
  end

  test 'should create ticket' do
    assert_difference('Ticket.count') do
      post tickets_url, params: { ticket: {} }, as: :json
    end

    assert_response :created
  end

  test 'should show ticket' do
    get ticket_url(@ticket), as: :json
    assert_response :success
  end

  test 'should update ticket' do
    patch ticket_url(@ticket), params: { ticket: {} }, as: :json
    assert_response :ok
  end

  test 'should destroy ticket' do
    assert_difference('Ticket.count', -1) do
      delete ticket_url(@ticket), as: :json
    end

    assert_response :no_content
  end
end
