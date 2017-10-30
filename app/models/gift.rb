class Gift < ApplicationRecord
  acts_as_taggable

  VALID_TAG_REGEXP = /^[a-z0-9][a-z0-9_]*$/i

  validates :title, presence: true
  validates :description, presence: true
  validates :wrapt_sku, presence: true
  validate :validate_tag
  validate :_has_boxes, if: :available?
  validate :_has_products, if: :available?
  validate :_has_price, if: :available?
  validate :_has_weight, if: :available?
  validate :_has_cost , if: :available?

  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products

  has_many :gift_images, -> {order :sort_order}, inverse_of: :gift, dependent: :destroy

  def carousel_images
    # PT story #152292601
    # we want the first image in the carousel to be the primary image
    # primary then sort order
    gift_images.sort_by {|image| image == primary_gift_image ? 0 : 1}
  end

  def carousel_thumb
    # PT story #152292601
    # try to find a primary image that is landscape
    # if none find the first landscape in sort_order
    # if no landscape use primary image portrait
    primary = primary_gift_image
    if primary.orientation == 'landscape'
      thumb = primary
    else
      first_landscape = gift_images.select{|gi| gi.orientation == 'landscape'}.first
      thumb = first_landscape || primary
    end
  end

  has_many :uploaded_gift_images, class_name: 'GiftImages::Uploaded'
  has_many :gift_images_from_products, class_name: 'GiftImages::FromProduct'

  has_many :gift_parcels, dependent: :destroy
  has_many :pretty_parcels, -> { joins(:parcel).where(parcels: { usage: 'pretty' }) }, class_name: 'GiftParcel'
  has_many :shipping_parcels, -> { joins(:parcel).where(parcels: { usage: 'shipping' }) }, class_name: 'GiftParcel'
  define_method(:pretty_parcel) { pretty_parcels.first&.parcel }
  define_method(:shipping_parcel) { shipping_parcels.first&.parcel }

  # TODO bug ?
  # when a new product is added to the gift
  # the product primary image gets set as a primary image for a gift
  # this can cause a gift to have more than one primary image.
  # take the first one in the sort order for now.
  has_one :primary_gift_image, -> {where(primary: true).order(:sort_order)}, class_name: 'GiftImage'

  belongs_to :source_product, class_name: 'Product', required: false

  belongs_to :product_category, required: true
  belongs_to :product_subcategory, required: true, class_name: 'ProductCategory'
  belongs_to :tax_code, class_name: 'Tax::Code'

  has_one :calculated_gift_field
  delegate :units_available, to: :calculated_gift_field, allow_nil: true

  before_validation -> { self.tax_code ||= Tax::Code.default }

  before_save :generate_wrapt_sku, if: :sku_needs_updating?
  before_save :set_can_be_sold_flag

  before_destroy -> { raise "Cannot destroy" unless deleteable? }

  accepts_nested_attributes_for :pretty_parcels
  accepts_nested_attributes_for :shipping_parcels

  scope :available, -> { where(available: true) }
  scope :with_units_for_sale, -> { joins(:calculated_gift_field).where('calculated_gift_fields.units_available > 0') }
  scope :can_be_sold, -> { where(can_be_sold: true) }

  def set_can_be_sold_flag
    self.can_be_sold = available? && units_available.to_i > 0
  end

  def self.search search_params
    self.all.merge(GiftSearch.new(search_params).to_scope)
  end

  def deleteable?
    LineItem.where(orderable: self).none?
  end

  def vendor
    # Assumption is that all the products of a gift are the same vendor
    products.first.vendor
  end

  def experience?
    product_subcategory.wrapt_sku_code == ProductCategory::EXPERIENCE_GIFT_CODE
  end

  def availability_string
    if available?
      "Available"
    else
      "Not available"
    end
  end

  def name
    title
  end

  def cost
    if calculate_cost_from_products?
      calculated_gift_field&.cost
    else
      read_attribute(:cost)
    end
  end

  def selling_price
    if calculate_price_from_products?
      calculated_gift_field&.price
    else
      read_attribute(:selling_price)
    end
  end

  def weight_in_pounds
    if calculate_weight_from_products?
      calculated_gift_field&.weight_in_pounds
    else
      read_attribute(:weight_in_pounds)
    end
  end

  def validate_tag
    tag_list.each do |tag|
      errors.add(:tag_list, "-#{tag}- tag names can only contain alphanumeric characters or underscore") unless tag =~ VALID_TAG_REGEXP
    end
  end

  def _has_boxes
    return if pretty_parcel.present? && shipping_parcel.present?

    errors.add(:base, "Must have a gift box and shipping box")
  end

  def _has_products
    return if products.present?

    errors.add(:base, "Must have at least one product")
  end

  def _has_weight
    if calculate_weight_from_products && self.products.all? { |x| x.weight_in_pounds.to_f > 0.0 }
      return
    elsif !calculate_weight_from_products && read_attribute(:weight_in_pounds).to_f > 0.0
      return
    end

    errors.add(:base, "Must have a weight")
  end

  def _has_price
    if calculate_price_from_products && self.products.all? { |x| x.price.to_f > 0.0 }
      return
    elsif !calculate_price_from_products && read_attribute(:selling_price).to_f > 0.0
      return
    end

    errors.add(:base, "Must have a selling price")
  end

  def _has_cost
    if calculate_cost_from_products && self.products.all? { |x| x.wrapt_cost.to_f > 0.0 }
      return
    elsif !calculate_cost_from_products && read_attribute(:cost).to_f > 0.0
      return
    end

    errors.add(:base, "Must have a cost")
  end

  private def sku_prefix
    segments = []
    segments << "G"

    vendor_sku = vendor_product&.vendor&.wrapt_sku_code.presence || "XX"
    segments << vendor_sku

    category_sku = product_category&.wrapt_sku_code.presence || "XXX"
    segments << category_sku

    subcategory_sku = product_subcategory&.wrapt_sku_code.presence || "XXX"
    segments << subcategory_sku

    segments.join("-")
  end

  def sku_unique_id
    wrapt_sku.split('-').last
  end

  def generate_wrapt_sku
    others_with_prefix = Gift.where("wrapt_sku LIKE ?", "#{sku_prefix}%")
    last_sku_unique_id = others_with_prefix.order(:wrapt_sku).last&.sku_unique_id || "000"
    next_sku_unique_id = format "%03d", (last_sku_unique_id.to_i + 1)

    self.wrapt_sku = "#{sku_prefix}-#{next_sku_unique_id}"
  end

  def generate_wrapt_sku! **save_opts
    generate_wrapt_sku
    save({validate: false}.merge save_opts)
  end

  private def sku_needs_updating?
    product_category_id_changed? ||
    product_subcategory_id_changed?
  end

  def vendor_product
    products.first
  end

  def self.default_product_category
    ProductCategory.where(wrapt_sku_code: 'GFT').first_or_create!(name: 'Gift')
  end

  def single_product_gift?
    source_product_id.present?
  end

  def primary_gift_image_with_fallback
    primary_gift_image || gift_images.first || GiftImage.new
  end

  def duplicate_single_product_gift
    if source_product_id.blank? && gift_products.size == 1
      gift_products.first.product.single_product_gift
    else
      nil
    end
  end

  ################################################################################
  # These associations are not used directly in this direction by the application
  # they're only here to allow foreign keys to be cleaned up via dependent destroy
  ################################################################################

  has_many :gift_recommendations, dependent: :destroy
  # not sure why the association below exists?
  #has_many :survey_responses, dependent: :destroy
  has_many :gift_selections, dependent: :destroy
  has_many :recipient_gift_likes, dependent: :destroy
  has_many :recipient_gift_dislikes, dependent: :destroy
  has_many :gift_dislikes, dependent: :destroy
  has_many :gift_likes, dependent: :destroy

  ###########################
  # end unused foreign-key cleanup associations
  ###########################

end
