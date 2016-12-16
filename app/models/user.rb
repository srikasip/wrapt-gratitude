class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable#,  :registerable # only predefined users for now

  # TODO we need some better logic here
  def password_required?
    false
  end

  def full_name
    [first_name, last_name].compact.join(" ")
  end
end
