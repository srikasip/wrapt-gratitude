class PrivateAccessSession
  include ActiveModel::Model

  attr_accessor :access_code

  validate :validate_correct_access_code

  def save
    valid?
  end

  def validate_correct_access_code
    unless access_code == 'wrapataptap'
      errors.add :access_code, 'is not correct'
    end
  end

end