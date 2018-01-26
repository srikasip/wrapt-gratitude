class window.PjaxCarousel
  constructor: (carousel_selector, slide_selector, link_selectors)->
    @carousel_selector = carousel_selector
    @slide_selector = slide_selector
    @linkTriggers = $("#{carousel_selector} #{link_selectors}")
    @carousel = $(carousel_selector)
    $.pjax.defaults.scrollTo = false
    @_registerLinks()

  _registerLinks: ->
    $('body').pjax @linkTriggers.selector, @carousel.selector, timeout: false, push: false, scrollTo: false


class window.PjaxCarouselLoadMore
  constructor: (container_selector, link_selector, close_selector)->
    @container_selector = container_selector
    @container = $(container_selector)

    @close_selector = "#{container_selector} #{close_selector}"

    @close_trigger_selector = '[data-pjax-load-more-close]'

    @link_selector = link_selector
    @_registerLinks()

  _registerLinks: ->
    $('body').pjax @link_selector, @container.selector, timeout: false, push: false
    $('body').on 'click', @close_trigger_selector, (e) =>
      e.preventDefault()
      @_close()

  _close: ->
    $(@close_selector).hide()

class window.GiftImageCarousel
  constructor: (carousel_selector, image_selector, slides_selector) ->
    @carousel_selector = carousel_selector
    @carousel = $(@carousel_selector)

    @image_selector = "#{carousel_selector} #{image_selector}"
    @image = $(@image_selector)

    @slides_selector = "#{carousel_selector} #{slides_selector}"
    @slides = $(@slides_selector)

    @debounce = window.CarouselDebounce

    @_setHeight()
    resize = _.debounce(@_setHeight.bind(@), 1000)
    $(window).resize resize

  _setHeight: ->
    @_setCarouselHeight()
    $('.zoomContainer').remove()
    width = $(window).width()
    if width > 768
      @elevateZoom = @image.elevateZoom()
    else
      # remove zoom on mobile
      # @elevateZoom = @image.elevateZoom({
      #   zoomType: 'inner'
      # })


  _setCarouselHeight: ->
    height = @carousel.parent('div').height()
    @carousel.css('height', height)
    @slides.css('height', height)
    @slides.parent('div').css('height', height)
    @image.css('height', height)


class window.GiftCarousel
  constructor: (carousel_selector, indicators_selector, slides_selector, mobile_indicators) ->
    @carousel_selector = carousel_selector
    @carousel = $(carousel_selector)

    @indicators_selector = "#{carousel_selector} #{indicators_selector}"
    @indicators = $(@indicators_selector)

    @mobile_indicators_selector = "#{carousel_selector} #{mobile_indicators}"

    @slides_selector = "#{carousel_selector} #{slides_selector}"
    @slides = $(slides_selector)

    @height = 520
    @debounce = window.CarouselDebounce
    @_setHeight()
    @_setMobileClickEvents()
    resize = _.debounce(@_setHeight.bind(@), 1000)
    $(window).resize resize

  _setHeight: ->
    @_setCarouselHeight()
    @_setWrapperHeight()

  _setWrapperHeight: ->
    width = $(window).width()
    if width > 767
      wrapperHeight = @height
      # wrapperHeight += (parseInt(@indicators.height()) || 0)
      mt = parseInt(@indicators.css('margin-top') || 0)
      mb = parseInt(@indicators.css('margin-bottom') || 0)
      # gh = parseInt(@indicators.find('.gr-carousel__indicators-group').height() || 0)
      gh = 111
      wrapperHeight += parseInt((@indicators.find('.gci_show').length || 0) * gh) + mt + mb
      wrapperHeight += mt
      wrapperHeight += 'px'
    else
      wrapperHeight = 'auto'
    $('.wrapt-carousel--wrapper').css('height', wrapperHeight)

  _setCarouselHeight: ->
    screenWidth = $(window).width()
    if screenWidth > 767
      height = @height + 'px'
    else
      height = 'auto'
    @carousel.css('height', height)
    @slides.css('height', height)

  _transitionMobileIndicators: ->
    indicators = $(@mobile_indicators_selector).find('a')
    to_show = $(@mobile_indicators_selector).find('a.hidden-xs')
    indicators.animate {opacity: 0}, 500, =>
      indicators.addClass('hidden-xs')
      indicators.css('opacity', 1)
      to_show.removeClass('hidden-xs')
      to_show.animate {opacity: 1}, 500

  _updateMobileNav: (a, b) ->
    behavior = 'data-behavior'
    # update to new behavior
    # pjax = 'data-loads-in-pjax-carousel-load-more'
    pjax = 'data-loads-in-pjax-modal-two'
    a.attr(behavior, 'scroll')
    a.removeAttr(pjax)
    a.removeClass('disabled')
    if(b.attr('href') == '#')
      b.addClass('disabled')
    else
      b.removeAttr(behavior)
      if(b.hasClass('more-recommendations__trigger'))
        b.attr(pjax, 'true')

  _setMobileClickEvents: ->
    next_selector = "#{@carousel_selector} .next[data-behavior=scroll]"
    prev_selector = "#{@carousel_selector} .prev[data-behavior=scroll]"
    $('body').on 'click', next_selector, (e) =>
      e.preventDefault()
      @_transitionMobileIndicators()
      prev = $("#{@carousel_selector} .prev")
      next = $(next_selector)
      @_updateMobileNav(prev, next)
    $('body').on 'click', prev_selector, (e) =>
      e.preventDefault()
      @_transitionMobileIndicators()
      next = $("#{@carousel_selector} .next")
      prev = $(prev_selector)
      @_updateMobileNav(next, prev)









