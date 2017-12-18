module PjaxCarouselController
  # This module sets up controllers to load their content in a carousel
  # in response to pjax requests.  See pjax-carousel.js.coffee for client side details
  #
  # calling render will render a template to the modal
  # and calling redirect_to will trigger a redirect on the underlying page
  #
  # note that inbound links should have `data-loads-in-pjax-carousel` attributes

  extend ActiveSupport::Concern

  included do
    layout ->(c) { pjax_request? ? pjax_layout : nil }
    after_action :set_pjax_url, if: :pjax_request?

    def redirect_to_with_xhr_redirect(*args)
      if pjax_request?
        if args.first.is_a? String
          # Needed this dumb if statement to make redirect_back work which was
          # trying to pass a url and an empty hash to url_for. url_for just
          # takes zero or one param.
          @redirect = url_for(args.first)
        else
          @redirect = url_for(*args)
        end
        render "redirect_via_js", layout: "pjax_carousel_content"
      else
        redirect_to_without_xhr_redirect(*args)
      end
    end
    alias_method_chain :redirect_to, :xhr_redirect

  end

  private

    def pjax_layout
      'pjax_carousel_content'
    end

    def pjax_request?
      request.env['HTTP_X_PJAX'].present?
    end

    def set_pjax_url
      response.headers['X-PJAX-URL'] = pjax_url
    end

    def pjax_url
      request.url
    end


end