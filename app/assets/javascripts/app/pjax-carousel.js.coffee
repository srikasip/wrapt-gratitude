class window.PjaxCarousel
  constructor: (carousel_selector, slide_selector, link_selectors)->
    @carousel_selector = carousel_selector
    @slide_selector = slide_selector
    @linkTriggers = $("#{carousel_selector} #{link_selectors}")
    @carousel = $(carousel_selector)
    @firstItemUrl = @carousel.data('first-item-url')
    $.pjax.defaults.scrollTo = false

    $.pjax({
      url: @firstItemUrl,
      container: @carousel,
      push: false
    })

  listen: ->
    @_registerLinks()

  _registerLinks: ->
    $('body').pjax @linkTriggers.selector, @carousel.selector, timeout: false, push: false, scrollTo: false


window.CarouselDebounce = (func, wait, immediate) ->
  result = null
  args = null
  timeout = null
  timestamp = null
  context = null
  later = () =>
    last = new Date - timestamp
    if last < wait && last >= 0
      timeout = setTimeout(later, wait - last)
    else 
      timeout = null
      if !immediate
        result = func.apply(context, args)
        if !timeout
          context = args = null
  () =>
    context = this
    args = arguments
    timestamp = new Date
    callNow = immediate && !timeout
    if !timeout
      timeout = setTimeout(later, wait)
    if callNow
      result = func.apply(context, args)
      context = args = null
    result 



class window.GiftImageCarousel
  constructor: (carousel_selector, image_selector, slides_selector) ->
    @carousel_selector = carousel_selector
    @carousel = $(carousel_selector)

    @image_selector = image_selector
    @image = $(image_selector)

    @slides_selector = slides_selector
    @slides = $(slides_selector)

    @debounce = window.CarouselDebounce

    @_setHeight()
    $(window).resize @debounce(@_setHeight, 1000)

  _setHeight: ->
    @_setCarouselHeight()
    $('.zoomContainer').remove()
    width = $(window).width()
    if width > 768
      @elevateZoom = @image.elevateZoom()
    else
      @elevateZoom = @image.elevateZoom({
        zoomType: 'inner'
      })


  _setCarouselHeight: ->
    height = @carousel.parent('div').height()
    @carousel.css('height', height)
    @slides.css('height', height)
    @slides.parent('div').css('height', height)
    @image.css('height', height)


class window.GiftCarousel
  constructor: (carousel_selector, indicators_selector, slides_selector) ->
    @carousel_selector = carousel_selector
    @carousel = $(carousel_selector)

    @indicators_selector = indicators_selector
    @indicators = $(indicators_selector)

    @slides_selector = slides_selector
    @slides = $(slides_selector)

    @height = 520
    @debounce = window.CarouselDebounce
    @_setHeight()
    $(window).resize @debounce(@_setHeight, 1000)

  _setHeight: ->
    @indicators.find('.gci_show').slideDown()
    @indicators.find('.gci_hide').slideUp()
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





