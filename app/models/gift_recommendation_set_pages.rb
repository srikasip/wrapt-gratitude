class GiftRecommendationSetPages

  RECS_PER_PAGE = 6

  def initialize(profile, page_params)
    @profile = profile
    @page_params = page_params
    @recommendations = profile.display_gift_recommendations
  end

  def page_recommendations
    pages[active_page_index] || []
  end

  def prev_page
    prev_page_index + 1
  end

  def next_page
    next_page_index + 1
  end

  def active_page
    active_page_index + 1
  end

  def prev_page_index
    active_page_index <= 1 ? 0 : active_page_index-1
  end

  def next_page_index
    active_page_index >= last_page_index ? last_page_index : active_page_index+1
  end

  def active_page_index
    if @page_params.present?
      # if there is a specific page present make sure it makes sense
      active_index = find_page_index_with_params
    else
      # find the first page with recs that haven't been viewd
      active_index = find_page_index_with_viewed_status
    end
    active_index
  end

  def pages
    @recommendations.in_groups_of(RECS_PER_PAGE, false)
  end

  def page_count
    pages.size
  end

  def last_page_index
    page_count - 1
  end

  private

  def page_index(page)
    index = page - 1
    if index < 0
      index = 0
    elsif index > last_page_index
      index = last_page_index
    end
    index
  end

  def page_viewed_status(page)
    if page.map(&:viewed).include?(false)
      'unviewed'
    else
      'viewed'
    end
  end

  def find_page_index_with_params
    page_index(@page_params)
  end

  def find_page_index_with_viewed_status
    pages_viewed_status = pages.map do |page|
      page_viewed_status(page)
    end
    pages_viewed_status.index('unviewed') || 0
  end

end