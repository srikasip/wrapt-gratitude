class ProfileTraits::Facet < ApplicationRecord
  belongs_to :topic, class_name: 'ProfileTraits::Topic'
  has_many :tags, -> {order :position}, class_name: 'ProfileTraits::Tag', inverse_of: :facet, dependent: :destroy

  accepts_nested_attributes_for :tags

  def initialize_tags
    (-3..3).each do |i|
      unless tags.detect {|tag| tag.position == i}
        tags.new position: i
      end
    end
  end
end
