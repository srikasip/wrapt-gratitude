module AddressHelper
  def format_address(object:, prefix: '')
    get = ->(x) {
      msg = \
        if prefix.nil? || prefix == ''
          x.to_sym
        else
          (prefix+"_"+x.to_s).to_sym
        end

      if object.respond_to?(msg)
        object.send(msg)
      else
        nil
      end
    }

    csz = "#{get.(:city)}, #{get.(:state)} #{get.(:zip)}"

    [
      get.(:street1),
      get.(:street2),
      get.(:street3),
      csz,
      get.(:country)
    ].select(&:present?).join('<br>').html_safe
  end
end
