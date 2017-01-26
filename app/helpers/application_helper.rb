module ApplicationHelper

  def active_top_nav_section
    controller_name
  end

  # override in specific helpers as needed
  def show_top_nav?
    true
  end

  def gift_basket_profile
    @profile || current_user&.mvp_profile
  end

  def gift_basket_count
    count = gift_basket_profile&.gift_selections&.count
    if count && count > 0
      "(#{count})"
    else
      ""
    end
  end

  def enable_gift_basket?
    gift_basket_profile.present?
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
    content_tag(:svg, content_tag(:use, "", 'xlink:href' => "\##{symbol_name}"), :class => options[:class])
  end



end
