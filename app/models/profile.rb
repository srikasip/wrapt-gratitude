class Profile < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :gift_recommendations, dependent: :destroy
  has_many :survey_responses, dependent: :destroy, inverse_of: :profile
  has_many :gift_selections, -> {order 'gift_selections.id'}, dependent: :destroy

  RELATIONSHIPS = [
    'Wife',
    'Girlfriend',
    'Mother',
    'Daughter',
    'Friend',
    'Sister',
    'Colleague',
    'Partner',
    'Other'
  ]
  validates :relationship, presence: true, on: :create, inclusion: {in: RELATIONSHIPS}

end
