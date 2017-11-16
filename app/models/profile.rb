# Alas, this is a giftee, not a profile. Do not confuse this with the concept
# of an account profile (i.e. the normal usage of profile).

class Profile < ApplicationRecord
  validates :first_name, presence: true

  belongs_to :owner, class_name: 'User'
  belongs_to :expert, class_name: 'User'
  has_many :addresses, as: :addressable
  # FIXME: which is the primary? That's incomplete.
  has_one :address, as: :addressable, class_name: "Address"
  has_many :gift_recommendations, -> {order 'gift_recommendations.expert_score desc, gift_recommendations.position, gift_recommendations.score desc, gift_recommendations.id'}, dependent: :destroy
  has_many :survey_responses, dependent: :destroy, inverse_of: :profile
  has_many :gift_selections, -> {order 'gift_selections.id'}, dependent: :destroy

  has_many :gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_selections, -> {order 'recipient_gift_selections.id'}, dependent: :destroy

  serialize :recommendation_stats, Hash

  before_create :generate_recipient_access_token

  accepts_nested_attributes_for :address

  scope :well_ordered, -> { order('first_name asc, last_name asc') }

  def relationship
    word = read_attribute(:relationship)

    if word == 'Other'
      survey_responses.first.question_responses.where("other_option_text != '' and other_option_text is not null").pluck(:other_option_text).first rescue 'Giftee'
    else
      word
    end
  end

  def last_survey
    survey_responses.order('updated_at desc').first
  end

  def name
    ([first_name, last_name].compact.join " ").strip
  end

  delegate :first_unanswered_response, to: :last_survey, prefix: false

  def finished_surveys?
    self.survey_responses.all? { |x| x.completed_at.present? }
  end

  def generate_recipient_access_token
    self.recipient_access_token = SecureRandom.urlsafe_base64(nil, false)
  end

  def selling_price_total
    gift_selections.map(&:gift).map(&:selling_price).sum
  end
end
