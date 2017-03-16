class InvitationRequest < ApplicationRecord

  belongs_to :invited_user, class_name: 'User', required: false
  validates :email, presence: true

  HOW_FOUNDS = {
    facebook: 'Facebook',
    twitter: 'Twitter',
    instagram: 'Instagram',
    linkedin: 'LinkedIn',
    web_search: 'Web Search',
    friend_family: 'Friend/Family'
  }.with_indifferent_access
  validates :how_found, inclusion: {in: HOW_FOUNDS.keys}, allow_nil: true

  scope :pending, -> {
    where(invited_user_id: nil)
  }

  def to_user
    user = User.new email: email
  end

  def humanized_how_found
    HOW_FOUNDS[how_found]
  end

end
