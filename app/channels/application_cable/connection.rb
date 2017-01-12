module ApplicationCable
  class Connection < ActionCable::Connection::Base

    def connect
      # TODO authorize by default?
    end

  end
end
