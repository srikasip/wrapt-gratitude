class SortableListOrderingsController < ApplicationController
  # Abstract controller for receiving updates from drag-and-drop sortable lists
  # expects params[:ordering] to be an array of ids of the desired order
  # Designed to work with the SortableListOrdering model
  # and the App.SortableList javascript class

  def create
    @sortable_list_ordering = SortableListOrdering.new sortables: sortables, ordering: create_params[:ordering], sort_order_attribute: sort_order_attribute
    @sortable_list_ordering.save
    head :ok
  end

  def create_params
    params.permit(ordering: [])
  end

  def sortables
    raise "Abstract Method.  Define me in the subclass"
  end

  def sort_order_attribute
    # override in subclass if necessary
    :sort_order
  end
  

end