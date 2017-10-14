module Tax
  class Code < ApplicationRecord
    has_many :gifts

    scope :active, -> { where(active: true) }

    if Rails.env.staging? || Rails.env.production?
      # I don't know what these are yet for sure.
      def self.default
        nil
      end
      def self.shipping
        nil
      end
    else
      def self.default
        @default ||= find_by(name: 'Generic')
      end

      def self.shipping
        @shipping ||= find_by(name: 'Generic Freight')
      end
    end
  end
end
