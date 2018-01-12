class ProfileNotifications
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def profiles
    @profiles || load_profiles
  end
  
  def load_profiles
    @profiles = Profile.where(%{
      profiles.id in (select grs.profile_id from gift_recommendations as gr
      join gift_recommendation_sets as grs on grs.id = gr.recommendation_set_id
      join profiles as p on grs.profile_id = p.id
      where
      p.owner_id = #{user.id}
      and grs.updated_at > '#{GiftRecommendationSet::TTL.ago.iso8601}'
      and gr.added_by_expert = true
      and gr.viewed = false)
    })
  end
  
  def count
    profiles.count
  end

end