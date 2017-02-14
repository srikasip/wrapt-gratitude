namespace :surveys do
  desc "Cleans up questions with multiple other options"
  task clean_up_duplicate_other_options: :environment do
    OtherOptionDeduplicator.new(test_mode: ENV['test_mode']).run!
  end
end


