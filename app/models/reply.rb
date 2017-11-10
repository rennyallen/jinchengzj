class Reply < ApplicationRecord
  include SoftDelete

  belongs_to :topic
  belongs_to :user
  has_many :comments, dependent: :destroy

  after_commit :update_correspondence, :notify_reply, on: :create
  after_destroy :update_after_delete_last_reply

  scope :without_event, -> { where(action: nil) }

  def update_correspondence
    topic.update_last_reply(self)
    user.update_replies_count
  end

  def update_after_delete_last_reply
    topic.update_to_previous_reply(self)
  end

  def notify_reply
    # Notification.create(
    #   notify_type: 'reply',
    #   actor: self.user,
    #   user: self.topic.user,
    #   target: self
    # )
  end

  def popular?
    'popular' if praises_count >= 5
  end

  def self.create_event(opts = {})
    opts[:body] = ""
    self.create!(opts)
  end
end
