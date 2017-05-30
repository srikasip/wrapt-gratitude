module ApplicationHelper

  def active_top_nav_section
    controller_name
  end

  # override in specific helpers as needed
  def show_top_nav?
    true
  end

  def gift_basket_profile
    @profile ||= current_user&.mvp_profile
  end

  def gift_basket_count
    count = gift_basket_profile&.gift_selections&.count
    if count && count > 0
      "#{count}"
    else
      ""
    end
  end

  def gift_basket_empty?
    count = gift_basket_profile&.gift_selections&.count
    count.blank? || count == 0
  end

  def enable_gift_basket?
    current_user && gift_basket_profile && !gift_basket_profile.new_record? && gift_basket_profile.gift_recommendations.any?
  end

  def render_gift_basket
    # note this is overridden for the recipient reviews
    render 'gift_selections/gift_basket', profile: gift_basket_profile
  end

  # path to svg files so we can include them like a partial
  # http://cobwwweb.com/render-inline-svg-rails-middleman#sthash.0TA73Fi9.dpuf
  def svg(name)
    file_path = "#{Rails.root}/app/assets/images/#{name}.svg"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end

  # embed an svg from a sprite (pick the symbol to use and give it a class)
  # should generate svg tag with classes passed surrounding a use tag with xlink:href att value of symbol_name
  def embedded_svg(symbol_name, options = {})
    content_tag(:svg, content_tag(:use, "", 'xlink:href' => "\##{symbol_name}", :class => options[:xlink_class]), :class => options[:class])
  end

  def body_classes
    [controller_name, params[:action], signin_state_body_class]
  end

  private def signin_state_body_class
    current_user ? 'signed-in' : 'not-signed-in'
  end

  def analytics_gifter_id
    gift_basket_profile&.owner_id
  end

  def analytics_profile_id
    gift_basket_profile&.id
  end

  def analytics_role
    case current_user
    when nil then 'guest'
    when ->(u) { u.admin? } then 'admin'
    when ->(u) { u.unmoderated_testing_platform? } then 'tester-loop11'
    when ->(u) { !u.unmoderated_testing_platform } then 'tester'
    end
  end



end
