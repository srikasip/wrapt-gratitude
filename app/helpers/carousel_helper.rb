module CarouselHelper

  def carousel(carousel: {}, unique_carousel_name:, slide_content_singular:, container: " ")
    slides = carousel[:slides]
    nav_partial = carousel[:nav_partial]
    if slides.present?
      classes = load_carousel_classes(unique_carousel_name, slide_content_singular, container)
      content_tag :div, class: "wrapt-carousel #{classes[:carousel]}", data: classes do
        unless slides.length == 1
          concat carousel_nav(nav_container_class: classes[:nav_container], nav_class: classes[:nav], nav_partial: nav_partial)
        end
        concat carousel_slide_container(slides: slides, slides_container: classes[:slides_container], slide_container: classes[:slide_container])
        concat carousel_indicators(slides: slides, indicators: classes[:indicators_container], indicator: classes[:indicator_container])
      end
    end
  end

  def load_carousel_classes(unique_carousel_name, slide_content_singular, container)
    {
      carousel: unique_carousel_name,
      slides_container: "#{unique_carousel_name}__#{slide_content_singular.pluralize(2)}",
      slide_container: "#{unique_carousel_name}__#{slide_content_singular}-container",
      indicators_container: "#{unique_carousel_name}__indicators",
      indicator_container: "#{unique_carousel_name}__indicator",
      nav_container: "#{unique_carousel_name}__nav-container",
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

  def carousel_nav(nav_container_class: nav_container_class, nav_class: nav_class, nav_partial: nav_partial)
    css_classes = {css_classes: {container: nav_container_class, link: "wrapt-carousel__nav #{nav_class}"}}
    render nav_partial, locals: css_classes
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

end