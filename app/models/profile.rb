class Profile < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :gift_recommendations, dependent: :destroy
  has_many :survey_responses, dependent: :destroy, inverse_of: :profile
  has_many :gift_selections, -> {order 'gift_selections.id'}, dependent: :destroy

end
