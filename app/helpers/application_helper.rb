module ApplicationHelper

  def active_top_nav_section
    controller_name
  end

  # override in specific helpers as needed
  def show_top_nav?
    true
  end

end
