class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, presence: true, uniqueness: true

  has_many :survey_responses, dependent: :destroy

  def full_name
    [first_name, last_name].compact.join " "
  end

  def active?
    activation_state == "active"
  end

  def self.search search_params
    self.all.merge(UserSearch.new(search_params).to_scope)        
  end

end
