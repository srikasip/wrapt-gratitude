class SetExistingGiftImagesToUploaded < ActiveRecord::Migration[5.0]
  def change
    GiftImage.update_all type: 'GiftImages::Uploaded'
  end
end
