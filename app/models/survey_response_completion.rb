class SurveyResponseCompletion
  # Form object for the Survey Completion Page
  # We collect the profile's email address (for the gift recipient)
  # and also set up their account if they haven't already

  include ActiveModel::Model

  attr_accessor :profile, :user
  delegate :email,
    :email=,
    to: :profile,
    prefix: true,
    allow_nil: true

  delegate :first_name,
    :first_name=,
    :last_name,
    :last_name=,
    :email,
    :email=,
    :password,
    :password=,
    :active?,
    :wants_newsletter=,
    :wants_newsletter,
    to: :user,
    prefix: true,
    allow_nil: true

  validates :user_email, :user_first_name, :user_last_name, :user_password, presence: true, unless: :user_active?

  def save
    if valid?
      save_result = profile.save && user.save
      if save_result && !user.active?
        user.activate!
      end

      return save_result
    else
      return false
    end
  end

  def persisted?
    false
  end

end
