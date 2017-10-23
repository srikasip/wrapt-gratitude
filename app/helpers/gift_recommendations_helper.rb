module GiftRecommendationsHelper

  def load_gift_recommendation_carousel_data(gift_recommendations)
    gifts = gift_recommendations.map do |gr|
      {
        slide_partial: 'gift',
        slide_locals: {gift: gr.gift, gift_recommendation: gr},
        thumbnail_partial: 'thumbnail',
        thumbnail_locals: {image: gr.gift.recommendation_thumbnail, gift: gr.gift},
      }
    end
    {nav_partial: 'gift_nav', slides: gifts}
  end

  def load_gift_image_carousel_data(gift_images)
    # only show portrait photos if possible
    images_to_show = gift_images.select{|gift_image| gift_image.orientation == 'portrait'}
    # if there are no portrait images to show just show all images
    if images_to_show.empty?
      images_to_show = gift_images
    end
    images = images_to_show.map do |gift_image|
      {
        slide_partial: 'gift_image',
        slide_locals: {
          image_url: gift_image.image_url(:small), 
          image_orientation: gift_image.orientation,
          zoom_url: gift_image.image_url(:large)
        },
        thumbnail_partial: 'gift_image_thumbnail',
        thumbnail_locals: {}
      }
    end
    {nav_partial: 'gift_image_nav', slides: images}
  end

  def existing_gift_like gift, profile
    profile.gift_likes.to_a.detect {|like| like.gift_id == gift.id}
  end

  def existing_gift_dislike gift, profile
    profile.gift_dislikes.to_a.detect {|dislike| dislike.gift_id == gift.id}
  end

  def like_reason_label key
    @_like_reason_labels ||= {
      maybe: "Maybe",
      like: "I like this",
      really_like: "I really like this",
      already_have_it: "Perfect but she already has it",
      would_like_more_options: "Would like more options similar to this"
    }.with_indifferent_access
    @_like_reason_labels[key]
  end

  def dislike_reason_label key
    @_dislike_reason_labels ||= {
      giftee_similar_item: "Already has this",
      giftee_dislike: "Wouldn't like it",
      too_expensive: "Too expensive",
      owner_dislike: "Just don't like it",
      no_reason: 'None of these'
    }.with_indifferent_access
    @_dislike_reason_labels[key]
  end
end