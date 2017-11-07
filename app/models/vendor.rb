class Vendor < ApplicationRecord
  has_many :products, inverse_of: :vendor, dependent: :destroy

  has_many :vendor_service_levels, class_name: 'Ec::VendorServiceLevel'
  has_many :shipping_service_levels, through: :vendor_service_levels

  validates :wrapt_sku_code, presence: true, format: {with: /\A[A-Z]{2}\z/, message: 'must be 2 uppercase letters'}, uniqueness: true

  validates :name, presence: true
  validates :street1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :phone, presence: true
  validates :email, presence: true
  validates :purchase_order_markup_in_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :_has_shipping_service_levels

  before_validation :upcase_wrapt_sku_code

  attr_accessor :skus_need_regeneration
  before_save :set_skus_need_regeneration, if: :wrapt_sku_code_changed?
  after_save :regenerate_dependent_skus!, if: :skus_need_regeneration

  before_destroy -> { raise "Cannot destroy" unless deleteable? }

  def deleteable?
    Ec::PurchaseOrder.where(vendor: self).none?
  end

  def purchase_order_markup_in_dollars
    purchase_order_markup_in_cents / 100.0
  end

  def purchase_order_markup_in_dollars= val
    self.purchase_order_markup_in_cents = val.to_f * 100.0
  end

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

  private def _has_shipping_service_levels
    return if shipping_service_levels.length > 0

    errors[:base] << "Vendor needs shipping choices"
  end
end
