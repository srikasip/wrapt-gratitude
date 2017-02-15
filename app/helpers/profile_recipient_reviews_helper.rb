module ProfileRecipientReviewsHelper
  
  def existing_gift_like gift, profile
    profile.recipient_gift_likes.to_a.detect {|like| like.gift_id == gift.id}
  end

end