class PromoCode < ApplicationRecord
  MODES = [
    PERCENT_MODE = 'percent',
    FIXED_MODE = 'fixed'
  ]

  before_validation :set_defaults

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :mode, inclusion: { in: MODES }
  validates :value, uniqueness: { case_insensitive: true }
  validates :value, length: { minimum: 4 }
  validates :amount, numericality: { greater_than: 0, integer_only: true }
  validate :_sane_amounts

  scope :well_sorted, ->       { order('end_date desc, start_date desc, value') }
  scope :future, ->            { where(':date < start_date', date: Date.today) }
  scope :current, ->           { where('start_date <= :date and :date <= end_date', date: Date.today) }
  scope :past, ->              { where('end_date < :date', date: Date.today) }
  scope :current_or_future, -> { where(':date <= end_date', date: Date.today) }

  define_method(:percent?)            { mode == PERCENT_MODE }
  define_method(:fixed?)              { mode == FIXED_MODE }
  define_method(:amount_in_cents)     { amount * 100 if fixed? }
  define_method(:percentage_in_maths) { amount / 100.0 if percent? }
  define_method(:future?)             { Date.today < start_date }
  define_method(:current?)            { start_date <= Date.today && Date.today <= end_date }
  define_method(:past?)               { end_date < Date.today }

  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today + 1.week
    self.mode ||= PERCENT_MODE
    self.amount ||= 10
  end

  def delta_in_cents cents
    delta = \
      if percent?
        (cents * percentage_in_maths).round
      elsif fixed?
        amount_in_cents
      else
        cents
      end

    delta < 0 ? 0 : delta
  end

  private

  def _sane_amounts
    if percent? && amount > 50
      errors[:amount] << "Percentage off can't be more than 50%"
    elsif fixed? && amount > 200
      errors[:amount] << "Fixed amount off can't be more than $200"
    end
  end
end
