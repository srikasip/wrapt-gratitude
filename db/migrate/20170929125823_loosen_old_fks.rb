class LoosenOldFks < ActiveRecord::Migration[5.0]
  def up
    begin
      say_with_time "Removing problematic foreign keys related to defunct tables preventing deletion of vendors" do
        execute <<~SQL
          ALTER TABLE training_set_response_impacts
            DROP constraint fk_rails_b48a03c485;

          ALTER TABLE evaluation_recommendations
            DROP CONSTRAINT fk_rails_0d540f40de,
            DROP CONSTRAINT fk_rails_233ae6f0fa,
            DROP CONSTRAINT fk_rails_f2f9a0258f;

          ALTER TABLE gift_question_impacts
            DROP CONSTRAINT fk_rails_5cd633a5f0,
            DROP CONSTRAINT fk_rails_6ad12784ff,
            DROP CONSTRAINT fk_rails_cf3fbfffed;
        SQL
      end
    rescue Exception
      puts "MIGRATION FAILED"
    end
  end
end
