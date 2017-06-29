class User < ApplicationRecord
  authenticates_with_sorcery!

  # TODO: change this to :mvp1a when the first MVP release + testing round starts
  CURRENT_ROUND = 'mvp1b'
  
  SOURCES = %w{admin_invitation requested_invitation recipient_referral unmoderated_testing_platform}
  BETA_ROUNDS = %w{pre_release_testing mvp1a mvp1b}

  ###########################
  ### Validations
  ###########################
  
  validates :email, presence: true, uniqueness: true
  validates :source, presence: true, inclusion: SOURCES
  validates :beta_round, presence: true, inclusion: BETA_ROUNDS

  ###########################
  ### Callbacks
  ###########################
  before_validation :set_beta_round, on: :create
  before_save :set_source

  ###########################
  ### Associations
  ###########################

  has_many :owned_profiles, class_name: 'Profile', foreign_key: :owner_id, dependent: :destroy
  belongs_to :last_viewed_profile, class_name: 'Profile'
  belongs_to :recipient_referring_profile, class_name: 'Profile'
  has_one :invitation_request, foreign_key: :invited_user_id

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

  private def set_beta_round
    self.beta_round = CURRENT_ROUND
  end
  
  private def set_source
    if unmoderated_testing_platform?
      self.source = 'unmoderated_testing_platform'
    end
  end

end
