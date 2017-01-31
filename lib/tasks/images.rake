namespace :images do
  desc "Update Gift and Product Image size versions"
  task recreate_versions: :environment do
    [GiftImage, ProductImage].each do |klass|
      puts "Updating #{klass.count} #{klass.to_s.pluralize}"
      klass.all.each do |image|
        begin
          image.image.recreate_versions!
          image.save!
          puts "#{klass}##{image.id}: OK"
        rescue Exception => e
          puts "#{klass}##{image.id}: #{e.message} #{e.backtrace.first}"
        end
      end
    end
  end

end
