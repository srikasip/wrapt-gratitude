# Alas, this is a giftee, not a profile. Do not confuse this with the concept
# of an account profile (i.e. the normal usage of profile).

class Profile < ApplicationRecord
  validates :first_name, presence: true
  validates :birthday_day, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31}, allow_nil: true, allow_blank: true
  validates :birthday_month, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12}, allow_nil: true, allow_blank: true
  validates :birthday_year, numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Date.today.year}, allow_nil: true, allow_blank: true

  belongs_to :owner, class_name: 'User'

  has_many :addresses, as: :addressable
  # FIXME: which is the primary? That's incomplete.
  has_one :address, as: :addressable, class_name: "Address"
  has_many :gift_recommendation_sets, dependent: :destroy
  
  has_many :survey_responses, dependent: :destroy, inverse_of: :profile
  has_many :gift_selections, -> {order 'gift_selections.id'}, dependent: :destroy

  has_many :gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_likes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_dislikes, inverse_of: :profile, dependent: :destroy
  has_many :recipient_gift_selections, -> {order 'recipient_gift_selections.id'}, dependent: :destroy

  # this can go away once the migrations have been run to copy and remove it.
  serialize :recommendation_stats, Hash

  before_create :generate_recipient_access_token

  addresses_blank_proc = proc do |attributes|
    [:street1, :city, :state, :zip].all? { |msg| attributes[msg].blank? }
  end
  accepts_nested_attributes_for :address, reject_if: addresses_blank_proc

  scope :well_ordered, -> { order('first_name asc, last_name asc') }

  scope :unarchived, -> {where(archived_at: nil)}
  scope :archived, -> {where.not(archived_at: nil)}

  def allow_new_recommendations!
    update_attribute(:recommendations_generated_at, nil)
  end

  def birthday
    return nil if birthday_month.blank? || birthday_day.blank?

    @birthday ||= Date.parse("#{birthday_year||1000}-#{"%02d"%birthday_month}-#{"%02d"%birthday_day}")
  end

  def archived?
    archived_at.present?
  end

  def unarchived?
    archived_at.blank?
  end

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

  def display_rec_set_last_update
    # set = gift_recommendation_sets.order(created_at: :desc).first
    set = most_recent_gift_recommendation_set
    if set.present?
      date = set.updated_at.strftime('%b %e, %l:%M %p')
    elsif recommendations_generated_at.present?
      date = recommendations_generated_at.strftime('%b %e, %l:%M %p')
    else
      nil
    end
  end

  def display_gift_recommendations
    gift_recommendations.
      where(gift_id: Gift.select(:id).can_be_sold, removed_by_expert: false).
      preload(
        recommendation_set: [:profile], 
        gift: [
          :gift_images, 
          :primary_gift_image, 
          :products, 
          :product_subcategory, 
          :calculated_gift_field
        ]
      )
  end

  def most_recent_gift_recommendation_set
    gift_recommendation_sets.order(created_at: :desc).first
  end
  
  def gift_recommendations
    GiftRecommendation.
      where(recommendation_set_id: gift_recommendation_sets.select(:id).order(created_at: :desc).limit(1))
  end
end
