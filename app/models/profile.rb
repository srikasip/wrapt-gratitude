class Profile < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :gift_recommendations, -> {order 'gift_recommendations.position, gift_recommendations.score desc, gift_recommendations.id'}, dependent: :destroy
  has_many :survey_responses, dependent: :destroy, inverse_of: :profile
  has_many :gift_selections, -> {order 'gift_selections.id'}, dependent: :destroy

  has_many :gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_selections, -> {order 'recipient_gift_selections.id'}, dependent: :destroy

  before_create :generate_recipient_access_token

  def generate_recipient_access_token
    self.recipient_access_token = SecureRandom.urlsafe_base64(nil, false)
  end
  
  def gift_recommendations_with_limit(max_total, min_random = 1)
    limited_recs = []
    
    min_random = 0 if min_random < 1
    all_recs = gift_recommendations.preload(
      gift: [:gift_images, :primary_gift_image, :products, :product_subcategory])
    
    if max_total == 1
      limited_recs << all_recs.first
    elsif max_total > 1
      non_random_recs = all_recs.reject(&:random?)
      random_recs = all_recs.select(&:random?)
      limited_recs += non_random_recs.take(max_total - min_random)
      limited_recs += random_recs.take(max_total - limited_recs.count)
    end
    
    limited_recs
  end
  

end
