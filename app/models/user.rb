class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, presence: true, uniqueness: true

  def full_name
    [first_name, last_name].compact.join " "
  end

  def active?
    activation_state == "active"
  end

end
