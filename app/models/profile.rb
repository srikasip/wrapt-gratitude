class Profile < ApplicationRecord
  validates :name, presence: true

  belongs_to :owner, class_name: 'User'
  has_many :gift_recommendations, -> {order 'gift_recommendations.position, gift_recommendations.score desc, gift_recommendations.id'}, dependent: :destroy
  has_many :survey_responses, dependent: :destroy, inverse_of: :profile
  has_many :gift_selections, -> {order 'gift_selections.id'}, dependent: :destroy

  has_many :gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_selections, -> {order 'recipient_gift_selections.id'}, dependent: :destroy

  serialize :recommendation_stats, Hash

  before_create :generate_recipient_access_token

  def generate_recipient_access_token
    self.recipient_access_token = SecureRandom.urlsafe_base64(nil, false)
  end

end
