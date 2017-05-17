module Recommender
  module Filtering
    class ExcludeTags < Base
      attr_reader :tag_names
      
      def load_params
        @tag_names = collect_tag_names(find_params('exclude_tags'))
      end
      
      def valid?
        tag_names.any?
      end
      
      def exclusive_scope?
        true
      end
      
      def gift_scope
        return nil unless valid?
        t = ActsAsTaggableOn::Tag.arel_table
        scope = Gift.joins(:tags).where(t[:name].in(tag_names))
        scope.select(:id)
      end
    end
  end
end