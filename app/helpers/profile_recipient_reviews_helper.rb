module ProfileRecipientReviewsHelper
  
  def existing_gift_like gift, profile
    profile.recipient_gift_likes.to_a.detect {|like| like.gift_id == gift.id}
  end

  def existing_gift_dislike gift, profile
    profile.recipient_gift_dislikes.to_a.detect {|dislike| dislike.gift_id == gift.id}
  end

  def dislike_reason_label reason_key
    @_reason_labels ||= {
      giftee_similar_item: "I already have this",
      giftee_dislike: "Just don't like it",
      too_expensive: "Too expensive",
      no_reason: 'None of these'
    }.with_indifferent_access
    @_reason_labels[reason_key]
  end

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