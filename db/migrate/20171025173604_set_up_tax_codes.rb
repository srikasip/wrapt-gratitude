class SetUpTaxCodes < ActiveRecord::Migration[5.0]
  def up
    begin
      load 'db/seeds/tax_codes.rb'
      food = ['From Aum to Yum',
              'Pure Sweetness',
              'Cacao Meets Yoga',
              'Flavor of Life',
              'Ancient Flavor',
              'Coffee in her Cup',
              'So Sweet',
              'Cool Entertainer',
              'Test Gift'
      ]
      say_with_time "Setting Up Tax Codes" do
        puts ""
        Gift.find_each do |gift|
          if gift.title.in?(food)
            gift.update_attribute(:tax_code_id, Tax::Code.food.id)
            print "F"
          else
            gift.update_attribute(:tax_code_id, Tax::Code.default.id)
            print "G"
          end
        end
        puts ""
      end
    rescue Exception => e
      puts "Data migration failed in #{__FILE__}: #{e.message}"
    end
  end

  def down
  end
end
