module ProfileRecipientReviewsHelper
  
  def load_gift_recommendation_carousel_data(gift_recommendations)
    gifts = gift_recommendations.map do |gr|
      {
        slide_partial: 'gift',
        slide_locals: {gift: gr.gift, gift_recommendation: gr},
        thumbnail_partial: 'thumbnail',
        thumbnail_locals: {image: (gr.gift.primary_gift_image || gr.gift.gift_images.first), gift: gr.gift},
      }
    end
    {nav_partial: 'gift_nav', slides: gifts}
  end

  def load_gift_image_carousel_data(gift_images)
    images = gift_images.map do |gift_image|
      {
        slide_partial: 'gift_image',
        slide_locals: {image_url: gift_image.image_url(:large), image_orientation: gift_image.orientation},
        thumbnail_partial: 'gift_image_thumbnail',
        thumbnail_locals: {}
      }
    end
    {nav_partial: 'gift_image_nav', slides: images}
  end
  
  def existing_gift_like gift, profile
    profile.recipient_gift_likes.to_a.detect {|like| like.gift_id == gift.id}
  end

  def existing_gift_dislike gift, profile
    profile.recipient_gift_dislikes.to_a.detect {|dislike| dislike.gift_id == gift.id}
  end

  def like_reason_label key
    @_like_reason_labels ||= {
      maybe: "Maybe",
      like: "I like this",
      really_like: "I really like this",
      already_have_it: "Perfect but I already have it",
      would_like_more_options: "Would like more options similar to this"
    }.with_indifferent_access
    @_like_reason_labels[key]
  end
  module_function :like_reason_label

  def dislike_reason_label reason_key
    @_reason_labels = {
      giftee_similar_item: "I already have this",
      giftee_dislike: "Just don't like it",
      too_expensive: "Too expensive",
      no_reason: 'None of these'
    }.with_indifferent_access
    @_reason_labels[reason_key]
  end
  module_function :dislike_reason_label

  def enable_gift_basket?
    true    
  end

  def render_gift_basket
    render 'recipient_gift_selections/gift_basket', profile: @profile
  end

  def gift_basket_profile
    @profile
  end

  def gift_basket_count
    count = gift_basket_profile&.recipient_gift_selections&.count
    if count && count > 0
      "#{count}"
    else
      ""
    end
  end

  def gift_basket_empty?
    count = gift_basket_profile&.recipient_gift_selections&.count
    count.blank? || count == 0
  end


end