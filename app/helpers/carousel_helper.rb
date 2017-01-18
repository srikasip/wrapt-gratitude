module CarouselHelper

  def carousel(slides: [], unique_carousel_name:, slide_content_singular:, container: " ")
    if slides.present?
      data = load_carousel_data(unique_carousel_name, slide_content_singular, container)
      content_tag :div, class: "wrapt-carousel #{data[:carousel]}", data: data do
        concat carousel_nav(direction: :prev, nav: data[:nav])
        concat carousel_slide_container(slides: slides, slides_container: data[:slides_container], slide_container: data[:slide_container])
        concat carousel_nav(direction: :next, nav: data[:nav])
        concat carousel_indicators(slides: slides, indicators: data[:indicators_container], indicator: data[:indicator_container])
      end
    end
  end

  def load_carousel_data(unique_carousel_name, slide_content_singular, container)
    {
      carousel: unique_carousel_name,
      slides_container: "#{unique_carousel_name}__#{slide_content_singular.pluralize(2)}",
      slide_container: "#{unique_carousel_name}__#{slide_content_singular}-container",
      indicators_container: "#{unique_carousel_name}__indicators",
      indicator_container: "#{unique_carousel_name}__indicator",
      nav: "#{unique_carousel_name}__nav",
      container: container
    }
  end

  def carousel_indicators(slides: slides, indicators: '', indicator: '')
    content_tag :div, class: "wrapt-carousel__indicators #{indicators}" do
      slides.each_with_index do |slide, index|
        concat carousel_indicator(slide: slide, index: index, indicator: indicator)
      end
    end
  end

  def carousel_indicator(slide: slide, index: index, indicator: '')
    locals = slide[:thumbnail_locals].merge({index: index + 1})
    link_to '#', class: "wrapt-carousel__indicator #{indicator}", data: {position: index + 1} do
      render slide[:thumbnail_partial], locals: locals
    end
  end

  def carousel_nav(direction: direction, nav: nav)
    directions = {prev: 'glyphicon-menu-left', next: 'glyphicon-menu-right'}
    link_to '#', class: "wrapt-carousel__nav #{nav} #{direction.to_s}" do
      concat carousel_nav_icon_wrapper(directions[direction])
    end
  end

  def carousel_nav_icon_wrapper(direction_class)
    content_tag :div, class: "wrapt-carousel-nav__icon-wrapper" do
      concat carousel_nav_icon(direction_class)
    end
  end

  def carousel_nav_icon(direction_class)
    content_tag :div, class: "wrapt-carousel-nav__icon" do
      concat content_tag :span, '', class: "glyphicon #{direction_class}"
    end
  end

  def carousel_slide_container(slides: slides, slides_container: '', slide_container: '')
    content_tag :div, class: "wrapt-carousel__slides #{slides_container}" do
      slides.each_with_index do |slide, index|
        concat content_tag :div, slide_content(slide: slide, index: index, slide_container: slide_container), class: "wrapt-carousel__slide #{slide_container}", data: {position: index + 1}
      end
    end
  end

  def slide_content(slide: slide, index: index, slide_container: '')
    render slide[:slide_partial], locals: slide[:slide_locals]
  end

  def dislike_options_content_id(gift)
    "gr-dislike__#{gift.id}"
  end

end