class User < ApplicationRecord
  authenticates_with_sorcery!

  CURRENT_ROUND = 'mvp1b'

  SOURCES = %w{admin_invitation requested_invitation recipient_referral unmoderated_testing_platform auto_create_on_quiz_taking}
  BETA_ROUNDS = %w{pre_release_testing mvp1a mvp1b}

  ###########################
  ### Validations
  ###########################

  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :source, presence: true, inclusion: SOURCES
  validates :beta_round, presence: true, inclusion: BETA_ROUNDS
  validates :email, format: { with: /\w+@\w+\.\w+/, message: 'must be well-formed' }

  ###########################
  ### Callbacks
  ###########################
  before_validation :set_beta_round, on: :create
  before_save :set_source
  before_validation -> {
    # Normalize the stored email to lowercase so our unique database index is
    # enforced case-insenstively like our rails validation intends.
    # We do this before validation so the uniqueness validation is working with the same
    # data as we send to the DB. That makes it a bit redundant with uniqueness: {case_sensitive: false}
    self.email = self.email.downcase
  }

  ###########################
  ### Associations
  ###########################

  has_many :addresses, as: :addressable
  has_many :comments, as: :commentable
  has_many :customer_orders, class_name: 'Ec::CustomerOrder' do
    def for_profile(p)
      where(profile_id: p.id)
    end
  end
  has_many :file_exports
  has_many :owned_profiles, class_name: 'Profile', foreign_key: :owner_id, dependent: :destroy
  belongs_to :last_viewed_profile, class_name: 'Profile'
  belongs_to :recipient_referring_profile, class_name: 'Profile'
  has_one :invitation_request, foreign_key: :invited_user_id
  
  has_many :expert_gift_recommendation_sets, class_name: 'GiftRecommendationSet', foreign_key: :expert_id, dependent: :nullify

  ###########################
  ### Methods
  ###########################

  delegate :how_found, :humanized_how_found,
    to: :invitation_request,
    prefix: true,
    allow_nil: true

  def full_name
    [first_name, last_name].compact.join " "
  end

  def active?
    activation_state == "active"
  end

  def self.search search_params
    self.all.merge(UserSearch.new(search_params).to_scope)
  end

  def has_other_giftees_with_relationship?(relationship)
    owned_profiles.where(relationship: relationship).any?
  end

  # MVP1a has users using a single profile
  def mvp_profile
    owned_profiles.last
  end

  def self.external
    t = User.arel_table
    self.where(admin: false).
     where.not(t[:email].matches('%@greenriver%')).
     where.not(t[:email].matches('%@wrapt%'))
  end

  def setup_activation
    self.activation_token_generated_at = Time.now
    super
  end

  private def set_beta_round
    self.beta_round = CURRENT_ROUND
  end

  private def set_source
    if unmoderated_testing_platform?
      self.source = 'unmoderated_testing_platform'
    end
  end
  
  def profile_notifications
    @_profile_notifications ||= ProfileNotifications.new(self)
  end

end
