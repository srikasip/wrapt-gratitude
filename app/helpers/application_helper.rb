module ApplicationHelper

  def load_home_page_carousel_data
    examples = GiftExamples.new().examples.map do |example|
      {
        slide_partial: 'home/wrapt_story',
        slide_locals: example,
        thumbnail_partial: 'home/wrapt_story_thumb',
        thumbnail_locals: {image: example[:image], title: example[:title]}
      }
    end
    {nav_partial: 'home/wrapt_stories_nav', slides: examples}
  end

  def active_top_nav_section
    @active_top_nav_section || controller_name
  end

  def top_nav_links
    links = []
    if current_user && current_user.active?
      links << [admin_root_path, 'Admin', :default] if current_user.admin?
      links << [my_account_path, 'My Account', :default]
    end
    links << [science_of_gifting_path, 'The Science', :default]
    links << ['#', 'Gift Basket', :gift_basket] if enable_gift_basket?
    if current_user
      links << [user_session_path, 'Sign Out', :default]
    else
      links << [new_user_session_path, 'Sign In', :default]
    end
    links
  end

  def top_nav_link(content)
    content_tag :span, class: 'top-navigation__menu-item' do
      concat content
    end
  end

  def top_nav_link_default(path, text)
    if text == 'Sign Out'
      content = link_to path, method: :delete do
        concat embedded_svg('icon-circle', class: 'icon navbar-static-top__icon-circle')
        concat " #{text}"
      end
    elsif text == 'Sign In'
      content = link_to path, data: {loads_in_pjax_modal: true, toggle: "fade out", target: '.top-navigation__menu'} do
        concat embedded_svg('icon-circle', class: 'icon navbar-static-top__icon-circle')
        concat " #{text}"
      end
    else
      content = link_to path do
        concat embedded_svg('icon-circle', class: 'icon navbar-static-top__icon-circle')
        concat " #{text}"
      end
    end
    top_nav_link(content)
  end

  def top_nav_link_gift_basket(path, text)
    a_data = {behavior: 'open-gift-basket', toggle: "fade out", target: '.top-navigation__menu'}
    a_onClick = "ga('send', 'event', 'basket', 'open-close', 'open');"
    count_data = {behavior: 'gift-basket-count'}
    count_classes = gift_basket_empty? ? 'gift-basket-count empty' : 'gift-basket-count'
    content = link_to path, data: a_data, onClick: a_onClick do
      concat embedded_svg('icon-circle', class: "icon navbar-static-top__icon-circle")
      concat " #{text}"
      concat content_tag :span, gift_basket_count, data: count_data, class: count_classes
    end
    top_nav_link(content)
  end

  def top_nav_toggle(action)
    css_classes = action == :in ? 'navbar-toggle' : 'navbar-toggle navbar-toggle__close'
    data = {toggle: "fade #{action.to_s}", target: '.top-navigation__menu'}
    content_tag :button, type: 'button', class: css_classes, data: data do
      if action == :in
        3.times do |time|
          concat content_tag :span, '', class: 'icon-bar'
        end
      elsif action == :out
        # '✕'
        embedded_svg('icon-close', class: 'modal__icon-close')
      end
    end
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

  def format_date date
    date.strftime("%b %e, %Y")
  end

  def content_quote(quote)
    content_tag :div, class: quote[:container] do
      concat content_tag :p, quote[:content].html_safe
      concat content_tag :small, quote[:credit].html_safe
    end
  end

  def content_section(content)
    content_tag :div, class: content[:container] do
      if content[:header].present?
        concat content_tag :h4, content_with_citation(content[:header][:text], content[:header][:citations]), class: 'about-page__header'
      end
      concat content_section_text(content[:content], content[:citations])
    end
  end

  def content_section_text(content, citations)
    content_tag :p do
      content.each_with_index do |c, index|
        cits = citations[index] || []
        concat content_with_citation(c, cits)
      end
    end
  end

  def content_with_citation(content, citations)
    content_tag :span do
      concat "#{content} ".html_safe
      citations.each_with_index do |cit, index|
        concat content_tag :sup, citation_link(index, citations)
      end
    end
  end

  def citation_link(index, citations)
    cit = citations[index]
    if index == citations.size - 1
      link_to cit, "#citation-0#{cit}"
    else
      succeed ',' do
        link_to cit, "#citation-0#{cit}"
      end
    end
  end

end
