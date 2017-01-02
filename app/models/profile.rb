class Profile < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :gift_recommendations, dependent: :destroy

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
