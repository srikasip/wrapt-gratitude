module ApplicationHelper

  def active_top_nav_section
    controller_name
  end

  def show_top_nav?
    !controller.devise_controller?
  end

end
