require 'csv'
namespace :direct_image_uploads do

  desc "Dump Uploaded Image info to a CSV file"
  task :dump => [:environment] do
    CSV.open "tmp/uploaded_images.csv", "wb" do |csv|
      csv << ["Type", "id", "image"]

      ProductImage.all.each do |product_image|
        csv << ["ProductImage", product_image.id, product_image.attributes['image']]
      end

      GiftImage.all.each do |gift_image|
        csv << ["GiftImage", gift_image.id, gift_image.attributes['image']]
      end

    end
  end

  desc "Reupload Images that were saved with the old name scheme"
  task :update_legacy => [:environment] do
    CSV.foreach "tmp/uploaded_images.csv", headers: true, header_converters: [:downcase, :symbol] do |row|
      klass = row[:type].constantize
      image_owner = klass.find(row[:id])
      image_filename = image_owner.attributes['image']
      if image_filename =~ /\d+-\d+-\d+-\d+\/.+/
        puts "[SKIP] #{klass}-#{row[:id]} #{image_filename}"
      else
        if Rails.env.development?
          image_owner.remote_image_url = "https://wrapt-gratitude-#{Rails.env}.s3.amazonaws.com/development-#{`whoami`.chomp}/uploads/#{klass.to_s.underscore}/image/#{image_owner.id}/#{image_filename}"
        else
          image_owner.remote_image_url = "https://wrapt-gratitude-#{Rails.env}.s3.amazonaws.com/uploads/#{klass.to_s.underscore}/image/#{image_owner.id}/#{image_filename}"
        end
        image_owner.image_processed = true
        begin
          image_owner.save!
          puts "[UPDATED] #{klass}-#{row[:id]} #{image_filename} => #{image_owner.attributes['image']}"
        rescue Exception => e
          puts "[ERROR] #{klass}-#{row[:id]} #{image_filename} #{e.inspect} #{image_owner.remote_image_url}"
        end
      end
    end
  end

end
