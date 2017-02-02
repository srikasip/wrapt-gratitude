class InvitationRequest < ApplicationRecord

  validates :email, presence: true

end
