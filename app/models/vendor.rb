class Vendor < ApplicationRecord
  has_many :products, inverse_of: :vendor, dependent: :destroy

  validates :wrapt_sku_code, presence: true, format: {with: /\A[A-Z]{2}\z/, message: 'must be 2 uppercase letters'}, uniqueness: true

  validates :name, presence: true
  validates :street1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :phone, presence: true
  validates :email, presence: true

  before_validation :upcase_wrapt_sku_code

  attr_accessor :skus_need_regeneration
  before_save :set_skus_need_regeneration, if: :wrapt_sku_code_changed?
  after_save :regenerate_dependent_skus!, if: :skus_need_regeneration

  private def set_skus_need_regeneration
    self.skus_need_regeneration = true
  end

  private def regenerate_dependent_skus!
    products.order(:wrapt_sku).each do |product|
      product.generate_wrapt_sku!
      product.regenerate_dependent_skus!
    end
  end

  private def upcase_wrapt_sku_code
    if wrapt_sku_code.present?
      self.wrapt_sku_code = wrapt_sku_code.upcase
    end
  end

end
