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

end