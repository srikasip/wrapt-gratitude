require 'csv'
class UserExport
  def self.csv
    notification_counts = Profile.with_notifications.group(:owner_id).count(:id)
    order_counts = Ec::CustomerOrder.where(status: Ec::CustomerOrder::PURCHASED).group(:user_id).count(:id)
    abandon_cart_counts = Profile.active.with_abandon_cart.group(:owner_id).count(:id)
    CSV.generate do |csv|
      csv << ['First Name', 'Last Name', 'Email Address', 'Newsletter Sign-up', 'Notifications', 'Orders', 'Abandon Carts']
      User.where("email not like '%greenriver%'").order('email').each do |user|
        csv << [
          user.first_name,
          user.last_name,
          user.email,
          (user.wants_newsletter ? 'Yes' : 'No'),
          (notification_counts[user.id].to_i),
          (order_counts[user.id].to_i),
          (abandon_cart_counts[user.id].to_i)
        ]
      end
    end
  end
end
