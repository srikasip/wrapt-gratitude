module GiftRecommendationsHelper

  MOBILE_INDICATORS = 4

  def mobile_indicators_to_show
    groups = @gift_recommendations.in_groups_of(MOBILE_INDICATORS, false)
    group = groups.select{|g| g.index(@gift_recommendation).present?}.first
    group || []
  end

  def mobile_nav_base_classes
    ['gr-carousel__sm-nav-link', 'grc_small_nav']
  end

  def mobile_nav_next_classes
    c = mobile_nav_base_classes
    c.push('next')
    if @gift_recommendations.size > MOBILE_INDICATORS
      if @gift_index >= MOBILE_INDICATORS && @page == @next_page
        c.push('disabled')
      end
    else
      if @page == @next_page
        c.push('disabled') 
      end
    end
    if !@profile.has_viewed_initial_recommendations?
      c.push('more-recommendations__trigger')
    end
    c
  end

  def mobile_nav_prev_classes
    c = mobile_nav_base_classes
    c.push('prev')
    if @gift_recommendations.size > MOBILE_INDICATORS
      if @gift_index < MOBILE_INDICATORS && @page == 1
        c.push('disabled')
      end
    else
      if @page == 1
        c.push('disabled') 
      end
    end
    c
  end

  def mobile_nav_next_data
    data = {}
    if @gift_recommendations.size > MOBILE_INDICATORS
      if @gift_index < MOBILE_INDICATORS
        data = {behavior: 'scroll'}
      elsif !@profile.has_viewed_initial_recommendations?
        data = {loads_in_pjax_modal_two: true}
      end
    elsif !@profile.has_viewed_initial_recommendations?
      data = {loads_in_pjax_modal_two: true}
    end
  end

  def mobile_nav_prev_data
    data = {}
    if @gift_recommendations.size > MOBILE_INDICATORS
      if @gift_index >= MOBILE_INDICATORS
        data = {behavior: 'scroll'}
      end
    end
  end

  def mobile_nav_next_path
    path = @page == @next_page ? '#' : giftee_gift_recommendations_path(@giftee_id, carousel_page: @next_page)
    if !@profile.has_viewed_initial_recommendations?
      path = giftee_survey_response_copy_path(@profile, @profile.last_survey, append: '1')
    end
    path
  end

  def mobile_nav_prev_path
    @page == 1 ? '#' : giftee_gift_recommendations_path(@giftee_id, carousel_page: @prev_page)
  end

  def gr_carousel_id
    if @override_gr_carousel_id.present?
      "gr-carousel-#{@override_gr_carousel_id}"
    else
      "gr-carousel-#{@gift.id}"
    end
  end

  def gr_image_carousel_id
    if @override_gr_carousel_id.present?
      "gr-image-carousel-#{@override_gr_carousel_id}"
    else
      "gr-image-carousel-#{@gift.id}"
    end
  end

  def gr_image_carousel_selector
    "##{gr_image_carousel_id}"
  end

  def gr_carousel_selector
    "##{gr_carousel_id}"
  end

  def indicators_index(mobile, index, group)
    if mobile
      index = (@page == 1 ? index : ((@page-1)*@mobile_max)+index)
    else
      index = (group == 0 ? index : (group*@max)+index)
    end
  end

  def gift_path(recommendation, opts={})
    giftee_gift_recommendation_path(
      @giftee_id, 
      recommendation, 
      direction: opts[:direction],
      carousel_page: opts[:page] || @page || 1,
      previous_page: opts[:previous]
    )
  end

  def gift_image_path(gift_image, opts={})
    giftee_gift_recommendation_image_path(
      @giftee_id,
      @gift_recommendation,
      gift_image,
      direction: opts[:direction],
      carousel_page: opts[:page] || @page || 1
    )
  end

  def direction_css_class
    css_classes = ['active']
    if @direction == 'next'
      css_classes.push('slideInLeft')
    elsif @direction == 'prev'
      css_classes.push('slideInRight')
    end
    css_classes
  end

  def load_gift_recommendation_carousel_data(gift_recommendations)
    gifts = gift_recommendations.map do |gr|
      {
        slide_partial: 'gift',
        slide_locals: {gift: gr.gift, gift_recommendation: gr},
        thumbnail_partial: 'thumbnail',
        thumbnail_locals: {image: gr.gift.carousel_thumb, gift: gr.gift},
      }
    end
    {nav_partial: 'gift_nav', slides: gifts, small_nav_max_elements: 4}
  end

  def load_gift_image_carousel_data(gift_images)
    images = gift_images.map do |gift_image|
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