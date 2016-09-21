class ProductImageOrdering

  attr_reader :product, :ordering

  def initialize attrs
    @product = attrs.fetch :product
    @ordering = attrs.fetch :ordering
  end

  def save
    product_images = @product.product_images.to_a
    ordering.each_with_index do |product_image_id, i|
      product_images.detect{|product_image| product_image.id == product_image_id.to_i}.update sort_order: i+1
    end
  end


end