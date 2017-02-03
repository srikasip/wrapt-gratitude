class InvitationRequest < ApplicationRecord

  belongs_to :invited_user, class_name: 'User', required: false
  validates :email, presence: true

  scope :pending, -> {
    where(invited_user_id: nil)
  }

  def to_user
    user = User.new email: email
  end

end
