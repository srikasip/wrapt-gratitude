class AddMvp1bUserSurvey < ActiveRecord::Migration[5.0]
  def change
    create_table :mvp1b_user_surveys do |t|
      t.references :user
      t.string  :age
      t.string  :gender
      t.string  :zip
      t.string  :response_confidence
      t.string  :recommendation_confidence
      t.text    :recommendation_comment
      t.string  :would_use_again
      t.string  :would_tell_friend
      t.string  :would_create_wish_list
      t.string  :would_pay
      t.text    :pay_comment
      t.text    :other_services
      t.text    :mailing_address

      t.timestamps
    end
  end
end
