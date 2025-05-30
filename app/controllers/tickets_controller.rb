# frozen_string_literal: true

class TicketsController < ApplicationController
  def new
    raise ActionController::RoutingError, 'ログイン状態で TicketController#new にアクセス'
  end

  def create
    event = Event.find(params[:event_id])
    @ticket = current_user.tickets.build do |t|
      t.event = event
      t.comment = params[:ticket][:comment]
    end
    redirect_to event, notice: 'このイベントに参加表明しました' if @ticket.save
  end

  def destroy
    ticket = current_user.tickets.find_by(event_id: params[:event_id])
    ticket.destroy!
    redirect_to event_path(params[:event_id]), notice: 'このイベントの参加をキャンセルしました'
  end
end
