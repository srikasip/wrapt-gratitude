class RemoveDuplicateOtherOptions < ActiveRecord::Migration[5.0]
  def up
    say_with_time "Removing superfluous SurveyQuestionOtherOption rows" do
      SurveyQuestion.find_each do |question|
        possible_dups = question.
          options.
          select { |x| x.type == 'SurveyQuestionOtherOption' }.
          sort_by { |x| x.sort_order }

        next if possible_dups.length <= 1

        possible_dups[0..-2].each do |dup|
          dup.destroy
        end
      end
    end
  end

  def down
  end
end
