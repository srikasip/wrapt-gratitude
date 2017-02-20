class RecipientOriginatedReferral
  # form object to control the modal when a Gift Recipient checks out of their
  # gift basket and invites friends to Wrapt

  include ActiveModel::Model

  attr_accessor :emails

  validates :emails, presence: true

  def save
    if valid?
      emails.split(/, */).each do |email|
        user = User.new
        user.email = email
        user.setup_activation
        user.source = :recipient_referral
        if user.save
          UserActivationsMailer.activation_needed_email(user).deliver_later
        end
      end
    end
  end

  def persisted?
    false
  end

end