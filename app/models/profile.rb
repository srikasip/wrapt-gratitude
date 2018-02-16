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
  has_many :customer_orders, class_name: 'Ec::CustomerOrder', dependent: :nullify
  
  # this can go away once the migrations have been run to copy and remove it.
  serialize :recommendation_stats, Hash

  addresses_blank_proc = proc do |attributes|
    [:street1, :city, :state, :zip].all? { |msg| attributes[msg].blank? }
  end
  accepts_nested_attributes_for :address, reject_if: addresses_blank_proc

  scope :well_ordered, -> { order('first_name asc, last_name asc') }

  scope :unarchived, -> {where(archived_at: nil)}
  scope :archived, -> {where.not(archived_at: nil)}

  TTL = 30.days
  
  def self.all_active
    active_recommendation_sets = where(id: GiftRecommendationSet.active.select(:profile_id))
    previous_orders = where(id: Ec::CustomerOrder.where.not(status: Ec::OrderStatuses::ORDER_INITIALIZED).select(:profile_id))
    active_unfinished_survey_responses = where(id: SurveyResponse.active.incomplete.select(:profile_id))

    active_recommendation_sets.or(previous_orders).or(active_unfinished_survey_responses).where.not(relationship: nil, first_name: "Unknown")
  end
  
  def self.active
    unarchived.all_active
  end
    
  def self.with_notifications
    where(id: GiftRecommendationSet.current.with_notifications.select(:profile_id))
  end
  
  def active?
    unarchived? && current_gift_recommendation_set.present? || has_orders? || has_active_incomplete_survey_responses?
  end

  def has_orders?
    customer_orders.select(&:not_initialized?).any?
  end
  
  def has_active_incomplete_survey_responses?
    survey_reponses.select(&:active?).select(&:incomplete).any?
  end
  
  def self.with_abandon_cart
    where(id: GiftSelection.select(:profile_id)).
    where.not(id: Ec::CustomerOrder.where(status: Ec::CustomerOrder::PURCHASED).select(:profile_id))
  end

  def can_generate_more_recs?
    current_gift_recommendation_set.generation_number == 0
  end

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
      # FIXME: relationship is not always the first question
      survey_responses.first.question_responses.where("other_option_text != '' and other_option_text is not null").pluck(:other_option_text).first rescue 'Giftee'
    else
      word
    end
  end

  def last_survey
    @_last_survey ||= survey_responses.order('updated_at desc').first
  end

  def copy_last_survey_response!
    @_last_survey = survey_responses.create!(survey: last_survey.survey, completed_at: Time.now)
  end

  def name
    ([first_name, last_name].compact.join " ").strip
  end

  delegate :first_unanswered_response, :last_answered_response, to: :last_survey, prefix: false

  def finished_surveys?
    self.survey_responses.all? { |x| x.completed_at.present? }
  end

  def selling_price_total
    gift_selections.map(&:gift).map(&:selling_price).sum
  end

  def sorting_and_display_updated_at
    set = current_gift_recommendation_set
    if set.present?
      set.updated_at
    else
      updated_at
    end
  end

  def display_rec_set_last_update
    sorting_and_display_updated_at.strftime('%b %e, %l:%M %p')
  end

  def display_gift_recommendations
    gift_recommendations.
      available.
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
  
  def current_gift_recommendation_set
    if !defined?(@_current_gift_recommendation_set)
      t = GiftRecommendationSet.arel_table
      @_current_gift_recommendation_set =
        gift_recommendation_sets.active.
          preload(recommendations: {gift: :primary_gift_image}).
          order(created_at: :desc).first
    end
    @_current_gift_recommendation_set
  end
  
  def gift_recommendations
    if current_gift_recommendation_set.present?
      current_gift_recommendation_set.recommendations
    else
      GiftRecommendation.none
    end
  end
  
  def notification_count
    gift_recommendations.select(&:notify?).size
  end
  
  def generate_gift_recommendation_set!(params = {})
    params = {
      engine_type:      'survey_response_engine',
      max_total_new:    GiftRecommendationSet::MAX_TOTAL_NEW,
      append:           false
    }.merge(params)
    
    builder = Recommender::RecommendationSetBuilder.new(self, params)
    builder.build
    builder.save!
    @_current_gift_recommendation_set = builder.recommendation_set
  end

  def state_partial
    if current_gift_recommendation_set.blank?
      'my_account/giftees/refresh_recommendations'
    else
      'my_account/giftees/recommendations'
    end
  end
end
