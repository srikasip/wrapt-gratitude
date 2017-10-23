class FileExport < ApplicationRecord
  belongs_to :user

  validates :asset, presence: true
  validates :asset_type, inclusion: { in: ['products'] }

  mount_uploader :asset, CsvUploader
end
