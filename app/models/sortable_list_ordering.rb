class SortableListOrdering
  # Takes an array/scope of sortable items (e.g. @survey.questions)
  # and an ordering (an array of ids in the desired order, e.g. [1, 5, 3, 4, 2])
  # and an attribute that tracks the position on the sortable items (defaults to :sort_order)
  #
  # Calling save will set the attribute values from 1-n on the sortable items in
  # the order indicated by the ordering

  
  attr_reader :sortables, :ordering, :sort_order_attribute

  def initialize attrs
    @sortables = attrs.fetch :sortables
    @ordering = attrs.fetch :ordering
    @sort_order_attribute = attrs[:sort_order_attribute] || :sort_order
  end

  def save
    ordering.each_with_index do |sortable_id, i|
      sortables
        .detect{|sortable| sortable.id == sortable_id.to_i}
        .update sort_order_attribute => i+1
    end
  end


end