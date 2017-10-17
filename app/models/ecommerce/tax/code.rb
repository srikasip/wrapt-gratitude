module Tax
  class Code < ApplicationRecord
    has_many :gifts

    scope :active, -> { where(active: true) }

    def self.default
      @default ||= find_by(name: 'Generic')
    end

    def self.shipping
      @shipping ||= find_by(name: 'Generic Freight')
    end
  end
end
