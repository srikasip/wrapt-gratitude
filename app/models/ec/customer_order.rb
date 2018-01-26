module Ec
  class CustomerOrder < ApplicationRecord
    include ShippingComputer
    include OrderStatuses

    enum ship_to: {ship_to_customer: 0, ship_to_giftee: 1}

    has_paper_trail(
      ignore: [:updated_at, :created_at, :id],
      meta: {
        cart_id: :cart_id
      }
    )

    before_validation -> { self.status ||= ORDER_INITIALIZED }

    before_save :_set_submitted_date
    after_save :_update_gift_recommendation_set

    validates :status, inclusion: { in: VALID_ORDER_STATUSES }
    validates :order_number, presence: true

    validates :ship_street1, length: { minimum: 3 }, allow_blank: true
    validates :ship_city, presence: true, if: :ship_street1_present?
    validates :ship_state, inclusion: { in: UsaState.abbreviations }, if: :ship_street1_present?
    validates :ship_zip, length: { within: 5..10}, if: :ship_street1_present?
    validates :ship_country, inclusion: { in: ['US'], message: 'only supports US right now' }, if: :ship_street1_present?

    belongs_to :profile, touch: true
    belongs_to :user
    belongs_to :address

    has_one :charge, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :line_items, as: :order, dependent: :destroy
    has_many :related_line_items, dependent: :destroy

    has_many :gifts, through: :line_items, source_type: "Gift", source: :orderable

    has_many :shipments
    has_many :shipping_labels
    has_many :purchase_orders, dependent: :destroy
    has_many :tax_transactions, class_name: 'Tax::Transaction'

    scope :initialized_only, -> { where(status: ORDER_INITIALIZED) }
    scope :not_initialized, -> {where.not(status: ORDER_INITIALIZED)}
    define_singleton_method(:newest) { order('updated_at desc').first }

    delegate :email, :name, to: :user, prefix: true
    delegate :name, to: :profile, prefix: true

    define_method(:ship_street1_present?) { self.ship_street1.present?  }

    define_method(:subtotal_in_dollars)            { self.subtotal_in_cents / 100.0 } # gifts' amount, summed
    define_method(:promo_free_subtotal_in_dollars) { self.promo_free_subtotal_in_cents / 100.0 } # gifts' amount, summed
    define_method(:shipping_in_dollars)            { self.shipping_in_cents / 100.0 } # Shipping amount charged to customer
    define_method(:shipping_cost_in_dollars)       { self.shipping_cost_in_cents / 100.0 } # Wrapt's cost
    define_method(:taxes_in_dollars)               { self.taxes_in_cents / 100.0 } # duh, taxes.
    define_method(:handling_in_dollars)            { self.handling_in_cents / 100.0 }
    define_method(:handling_cost_in_dollars)       { self.handling_in_cents / 100.0 }
    define_method(:combined_handling_in_dollars)   { (self.shipping_in_cents + self.handling_in_cents) / 100.0 }
    define_method(:total_to_charge_in_dollars)     { self.total_to_charge_in_cents / 100.0 }
    define_method(:promo_total_in_dollars)         { self.promo_total_in_cents / 100.0 }

    define_method(:to_service)                     { PurchaseService.new(cart_id: self.cart_id) }

    define_method(:uncharged_gift_wrapt_fee_in_dollars)         { line_items.sum(&:quantity) * 8 }
    define_singleton_method(:uncharged_curation_fee_in_dollars) { 15 }

    define_method(:bad_charge?) { self.charge&.bad_state? }
    define_method(:bad_tax_transaction?) { self.tax_transactions.present? && !self.tax_transactions&.all?(&:success?) }
    define_method(:bad_labels?) { !self.shipping_labels.all?(&:success?) }

    define_method(:valid_note?) { include_note? && self.note_content.present? || self.note_envelope_text.present? }

    def not_initialized?
      status != ORDER_INITIALIZED
    end
    
    def non_cancelled_line_items
      line_items.reject do |line_item|
        purchase_order = line_item.related_order
        purchase_order.cancelled?
      end
    end

    def shipped_to_name
      return nil if shipments.length == 0

      names = shipments.map { |x| x.address_to['name'] }.uniq
      raise "what?" if names.length != 1
      names.first
    end

    def set_promo_code(promo)
      self.promo_code = promo.value
      self.promo_code_amount = promo.amount
      self.promo_code_mode = promo.mode
    end

    private

    def _set_submitted_date
      if self.status_changed?(to: SUBMITTED)
        self.submitted_on = Date.today
      end
    end
    
    def _update_gift_recommendation_set
      if status == SUBMITTED
        t = GiftRecommendationSet.arel_table
        # mark the recommendation sets associated with the profile
        # as stale so they can be refreshed by the user for the next round
        # of shopping
        GiftRecommendationSet
          .where(profile_id: profile_id)
          .where(t[:updated_at].lt(created_at))
          .update_all(stale: true)
      end
    end
  end
end
