module ApplicationHelper

  def image_tag_srcset(srcs)
    srcset = srcs.map do |src, size|
      "#{path_to_image(src)} #{size}"
    end.join(', ')
  end

  def load_home_page_carousel_data(stories_to_show)
    examples = GiftExamples.new.send(stories_to_show).map do |example|
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
      links << [my_account_profile_path, 'My Account', :default]
      links << [my_account_giftees_path, 'My Giftees', :default]
    end
    dropdown_links = []
    dropdown_links << [science_of_gifting_path, ' The Science']
    dropdown_links << [rewrapt_path, ' The Makers']
    dropdown_links << [about_path, ' About']
    links << ['#', 'About', :dropdown, dropdown_links]
    links << ['#', 'Gift Basket', :gift_basket] if enable_gift_basket?
    if current_user
      links << [user_session_path, 'Sign Out', :default]
    else
      if @sign_in_return_to
        links << [new_user_session_path(return_to: @sign_in_return_to), 'Sign In', :default]
      else
        links << [new_user_session_path, 'Sign In', :default]
      end
    end
    links
  end

  def top_nav_dropdown_link(path, text)
    link_to path do
      concat embedded_svg('icon-circle', class: 'icon navbar-static-top__icon-circle')
      concat text
    end
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
    elsif text == 'My Giftees'
      content = link_to path do
        concat embedded_svg('icon-circle', class: 'icon navbar-static-top__icon-circle')
        concat " #{text}"
        if current_user.profile_notifications.count > 0
          concat top_nav_link_notification
        end
      end
    else
      content = link_to path do
        concat embedded_svg('icon-circle', class: 'icon navbar-static-top__icon-circle')
        concat " #{text}"
      end
    end
    top_nav_link(content)
  end

  def top_nav_link_notification
    if current_user.present? && current_user.profile_notifications.count > 0
      content_tag :div, class: 'top-navigation__notification' do
        concat content_tag :span, current_user.profile_notifications.count
        concat embedded_svg('icon-wrapt-heart', class: 'svg-icon icon-notify navbar-static-top__icon-notify')
      end
    else
      ""
    end
  end

  def top_nav_link_gift_basket(path, text, options={})
    a_data = {behavior: 'open-gift-basket', toggle: "fade out", target: '.top-navigation__menu'}
    a_onClick = "ga('send', 'event', 'basket', 'open-close', 'open');"
    unless options[:hide_count]
      count_data = {behavior: 'gift-basket-count'}
      count_classes = gift_basket_empty? ? 'gift-basket-count empty' : 'gift-basket-count'
    end
    content = link_to path, data: a_data, onClick: a_onClick do
      unless options[:hide_circle_icon]
        concat embedded_svg('icon-circle', class: "icon navbar-static-top__icon-circle")
      end
      concat " #{text}"
      unless options[:hide_count]
        concat content_tag :span, gift_basket_count, data: count_data, class: count_classes
      end
      if options[:include_back_icon]
        concat embedded_svg('icon-caret-right', class: "icon navbar-static-top__icon-caret-right")
      end
    end
    top_nav_link(content)
  end

  def top_nav_toggle(action)
    css_classes = action == :in ? 'navbar-toggle' : 'navbar-toggle navbar-toggle__close pull-right'
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

  # override in specific helpers as needed
  def show_checkout_nav?
    false
  end

  def gift_basket_profile
    @profile ||= current_user&.last_viewed_profile
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
    return false if @hide_gift_basket

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
    if controller_path.split('/').first == 'my_account'
      # there were conflicts with other profiles controllers
      ["my_account_#{controller_name} my_account", params[:action], signin_state_body_class]
    else
      [controller_name, params[:action], signin_state_body_class]
    end
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

  def analytics_product_info(gift, profile, opts={})
    info = {
      id: gift.wrapt_sku,
      name: gift.title,
      category: "#{gift.product_category&.name}/#{gift.product_subcategory&.name}",
      brand: gift.wrapt_sku.split('-')[1],
      price: number_to_currency(gift.selling_price),
      dimension1: profile&.owner_id || -1,
      dimension4: opts[:promo] || 'n/a'
    }
    if opts[:position].present?
      info[:position] = opts[:position]
    end
    opts[:plain] ? info : info.to_json.html_safe
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
    return '' if date.nil?

    if date.year == 1000
      date.strftime("%b %e")
    else
      date.strftime("%b %e, %Y")
    end
  end

  def format_datetime datetime, with_zone: false
    return 'N/A' if datetime.nil?

    in_zone = datetime.in_time_zone('EST')
    format  = "%b %e, %Y %l:%M %p"

    result = \
      if datetime.dst?
        (in_zone + 1.hour).strftime(format)
      else
        in_zone.strftime(format)
      end

    result += " Eastern" if with_zone

    result
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

  def formatted_address_from_hash(address_hash)
    ah = OpenStruct.new(address_hash)

    (
    [ah.street1, ah.street2, ah.street3].compact.join("<br>") +
      [ah.city+',', ah.state, ah.zip].join(' ') +
      "<br>" +
      ah.country + "<br>" +
      ah.email
    ).html_safe
  end

  def next_button_text
    "NEXT <svg class='btn__icon-caret-right'><use xlink:href='#icon-caret-right'></use></svg>".html_safe
  end

  # this is a no object version of a simple form custom inputs

  def wrapt_radio_toggle(collection, attr_name, selected, options={})
    wrapper_class = "j-wrapt-radio-toggle form-group #{options[:wrapper_class]}"
    content_tag :div, class: wrapper_class do
      collection.each do |c|
        s = selected == c.last
        concat wrapt_radio_toggle_label_input(c, attr_name, s, options)
      end
    end
  end

  def wrapt_radio_toggle_label_input(collection_item, attr_name, selected, options={})
    label_key = "#{attr_name.to_s}_#{collection_item.last.to_s}".to_sym
    label_class = selected ? 'selected' : ''
    content_tag :label, for: label_key, class: label_class do
      concat collection_item.first
      concat radio_button_tag attr_name, collection_item.last, selected, style: 'display:none;', onChange: 'App.RadioToggle(this);', class: options[:input_class]
    end
  end

  def wrapt_styled_radio_button(value, attr_name, selected, options={})
    content_tag :label, for: "#{attr_name}_#{value}", class: 'wrapt-styled-radio-button j-wrapt-styled-radio-button' do
      concat link_to '', '#', class: (selected ? 'checked' : ''), onClick: 'App.StyledRadioButtonA(event, this)', data: {behavior: 'wrapted_styled_input'}
      concat (options[:label] || attr_name.humanize).html_safe
      concat radio_button_tag attr_name, value, selected, style: 'display:none;', onChange: 'App.StyledRadioButton(this);', class: options[:input_class], data: options[:data]
    end
  end

  def wrapt_styled_checkbox(value, attr_name, selected, options={})
    content_tag :label, for: attr_name, class: "wrapt-styled-checkbox j-wrapt-styled-checkbox" do
      concat link_to '', '#', class: (selected ? 'checked' : ''), onClick: 'App.StyledCheckboxA(event, this)', data: {behavior: 'wrapted_styled_input'}
      concat options[:label].html_safe
      concat check_box_tag attr_name, value, selected, {onChange: 'App.StyledCheckbox(this);', style: 'display:none;', data: options[:data]}
    end
  end

  # bootstrap tabs with wrapt style
  # currently only used on my account giftee page
  # must add page_js App.WraptStyledTabs('.wrapt-styled-tabs-1', '.wrapt-styled-tabs-1__tab'); to work properly

  # wrapt styled tabs 1
  def wrapt_styled_tabs_1(tabs)
    content = capture_haml do
      content_tag :div, class: 'wrapt-styled-tabs-1', role: 'tablist' do
        tabs.each do |tab|
          tab_classes = tab[:active] ? "wrapt-styled-tabs-1__tab active" : "wrapt-styled-tabs-1__tab"
          concat content_tag :div, bootstrap_tab_link(tab[:text], tab[:tab_pane_id]), class: tab_classes, role: 'presentation'
        end
      end
    end
    content_tag :div, content, class: 'wrapt-styled-tabs-1-container'
  end

  def bootstrap_tab_link(tab_text, tab_pane_id)
    link_to tab_text, "##{tab_pane_id}", role: 'tab', data: {toggle: 'tab'}, 'aria-controls' => tab_pane_id
  end

  def enable_chat?
    return false if ENV['DISABLE_CHAT']=='true'
    @enable_chat
  end
end
