module Recommender
  module Filtering
    class ExcludeTags < Base
      attr_reader :tag_names
      
      def load_params
        @tag_names = []
        params = find_params('exclude_tags')
        params.each do |excluded_tags|
          excluded_tags = Array.wrap(excluded_tags).map do |tag_name|
            tag_name.to_s.gsub(/[^a-z0-9_]/i, '')
          end.select(&:present?)
          @tag_names += excluded_tags
        end
        @tag_names.uniq!
      end
      
      def valid?
        tag_names.present?
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