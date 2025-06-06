# frozen_string_literal: true

class User < ApplicationRecord
  before_destroy :check_all_events_finished

  has_many :created_events, class_name: 'Event', foreign_key: 'owner_id', dependent: :nullify, inverse_of: :owner
  has_many :tickets, dependent: :nullify
  has_many :participating_events, through: :tickets, source: :event
  validates :name, presence: true

  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    nickname = auth_hash[:info][:nickname]
    image_url = auth_hash[:info][:image]

    User.find_or_create_by!(provider:, uid:) do |user|
      user.name = nickname
      user.image_url = image_url
    end
  end

  private

  def check_all_events_finished
    now = Time.zone.now
    errors.add(:base, '公開中の未終了イベントが存在します') if created_events.where(':now < end_at', now:).exists?
    errors.add(:base, '未終了の参加イベントが存在します') if participating_events.where(':now < end_at', now:).exists?

    throw(:abort) unless errors.empty?
  end
end
