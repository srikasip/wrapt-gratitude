require 'csv'
class UserExport
  def self.csv
    CSV.generate do |csv|
      csv << ['First Name', 'Last Name', 'Email Address', 'Newsletter Sign-up']
      User.where("email not like '%greenriver%'").order('email').each do |user|
        csv << [
          user.first_name,
          user.last_name,
          user.email,
          (user.wants_newsletter ? 'Yes' : 'No')
        ]
      end
    end
  end
end
