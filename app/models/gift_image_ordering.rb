class GiftImageOrdering

  attr_reader :gift, :ordering

  def initialize attrs
    @gift = attrs.fetch :gift
    @ordering = attrs.fetch :ordering
  end

  def save
    gift_images = @gift.gift_images.to_a
    ordering.each_with_index do |gift_image_id, i|
      gift_images.detect{|gift_image| gift_image.id == gift_image_id.to_i}.update sort_order: i+1
    end
  end


end