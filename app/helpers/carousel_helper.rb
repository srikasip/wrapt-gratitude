module CarouselHelper

  def carousel(carousel: {}, unique_carousel_name:, slide_content_singular:, container: " ", id: "", parent_slide_index: nil)
    slides = carousel[:slides]
    nav_partial = carousel[:nav_partial]
    if slides.present?
      classes = load_carousel_classes(unique_carousel_name, slide_content_singular, container)
      content_tag :div, id: id, class: "wrapt-carousel #{classes[:carousel]}", data: classes do
        unless slides.length == 1
          concat carousel_nav(nav_container_class: classes[:nav_container], nav_class: classes[:nav], nav_partial: nav_partial)
        end
        concat carousel_slide_container(slides: slides, slides_container: classes[:slides_container], slide_container: classes[:slide_container], parent_slide_index: parent_slide_index)
        concat carousel_indicators(carousel_classes: classes, slides: slides, indicators: classes[:indicators_container], indicator: classes[:indicator_container])
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
      small_nav: "#{unique_carousel_name}__sm-nav-link",
      small_nav_text: "#{unique_carousel_name}__sm-nav-text",
      container: container
    }
  end

  def carousel_indicators(carousel_classes: , slides: , indicators: '', indicator: '')
    is_gr_carousel = carousel_classes[:carousel] == 'gr-carousel'
    content_tag :div, class: "wrapt-carousel__indicators #{indicators}" do
      if is_gr_carousel
        concat carousel_small_indicator_nav(slides, carousel_classes)
      end
      slides.each_with_index do |slide, index|
        concat carousel_indicator(slide: slide, index: index, indicator: indicator, is_gr_carousel: is_gr_carousel)
      end
    end
  end

  def carousel_small_indicator_nav(slides, carousel_classes)
    content_tag :div, class: 'visible-xs' do
      concat link_to '< Prev 5', '#', class: "#{carousel_classes[:small_nav]} prev disabled", data: {group: 0}
      title = slides[0][:slide_locals][:gift].title
      concat content_tag :div, title, class: "#{carousel_classes[:small_nav_text]}"
      concat link_to 'Next 4 >', '#', class: "#{carousel_classes[:small_nav]} next", data: {group: 2}
    end
  end

  def carousel_indicator(slide: , index: , indicator: '', is_gr_carousel: false)
    locals = slide[:thumbnail_locals].merge({index: index + 1})
    base_classes = "wrapt-carousel__indicator #{indicator}"
    classes = (is_gr_carousel && index > 4) ? "#{base_classes} hidden-xs" : base_classes
    link_to '#', class: classes, data: {position: index + 1} do
      render slide[:thumbnail_partial], locals: locals
    end
  end

  def carousel_nav(nav_container_class: , nav_class: , nav_partial: )
    css_classes = {css_classes: {container: nav_container_class, link: "wrapt-carousel__nav #{nav_class}"}}
    render nav_partial, locals: css_classes
  end
  
  def carousel_slide_container(slides: slides, slides_container: '', slide_container: '', parent_slide_index: nil)
    content_tag :div, class: "wrapt-carousel__slides #{slides_container}" do
      slides.each_with_index do |slide, index|
        if slide[:slide_locals][:gift].present?
          title = slide[:slide_locals][:gift][:title]
        else
          title = ''
        end
        image_url = slide[:slide_locals][:image_url]
        if image_url.present? 
          concat content_tag :div, slide_content(slide: slide, index: index, slide_container: slide_container, parent_slide_index: parent_slide_index), class: "wrapt-carousel__slide #{slide_container}", data: {position: index + 1, title: title, zoom_image: image_path(image_url)}
        else
          concat content_tag :div, slide_content(slide: slide, index: index, slide_container: slide_container), class: "wrapt-carousel__slide #{slide_container}", data: {position: index + 1, title: title}
        end
      end
    end
  end

  def slide_content(slide: slide, index: index, slide_container: '', parent_slide_index: nil)
    render slide[:slide_partial], locals: slide[:slide_locals].merge({index: index, parent_slide_index: parent_slide_index})
  end

end
