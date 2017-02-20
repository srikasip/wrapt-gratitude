module PjaxModalController
  # This module sets up controllers to load their content in a modal
  # in response to pjax requests.  See pjax-modals.js.coffee for client side details
  # 
  # calling render will render a template to the modal
  # and calling redirect_to will trigger a redirect on the underlying page
  #
  # note that inbound links should have `data-loads-in-pjax-modal` attributes
  # and forms should have `data-submits-to-pjax-modal`

  extend ActiveSupport::Concern
  
  included do
    layout ->(c) { pjax_request? ? pjax_layout : nil }
    after_action :set_pjax_url, if: :pjax_request?

    def form_html_options
      Hash.new.tap do |result|
        result['data-submits-to-pjax-modal'] = true if pjax_request?
      end
    end
    helper_method :form_html_options
    
    def redirect_to_with_xhr_redirect(*args)
      if pjax_request?
        @redirect = url_for(*args)
        render "redirect_via_js", layout: "pjax_modal_content"
      else
        redirect_to_without_xhr_redirect(*args)
      end
    end
    alias_method_chain :redirect_to, :xhr_redirect
    
  end
  
  private

    def pjax_layout
      'pjax_modal_content'
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