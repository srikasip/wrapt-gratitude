module Recommender
  module Scoring
    class TagBoost < Base
      attr_reader :boost, :tag_names
      
      def load_params
        @boost = 1
        @tag_names = []
        params = find_params('boost_tags')
        params.each do |boost_tags|
          excluded_tags = Array.wrap(excluded_tags).map do |tag_name|
            tag_name.to_s.gsub(/[^a-z0-9_]/i, '')
          end.select(&:present?)
          @tag_names += boost_tags
        end
        @tag_names.uniq!
      end
      
      def valid?
        tag_names.any?
      end
      
      def scoring_sql
        return nil unless valid?
        
        sanitized_tag_list = tag_names.map do |tag_name|
          "'#{ActsAsTaggableOn::Tag.connection.quote_string(tag_name)}'"
        end.join(',')
        
        %{
          select gifts.id,
            (
              select #{boost.to_i} * count(tags.id)
              from tags join taggings on tags.id = taggings.tag_id
              where
              taggings.taggable_id = gifts.id and
              taggings.taggable_type = 'Gift' and
              taggings.context = 'tags' and
              tags.name in (#{sanitized_tag_list})
            ) as score
          from gifts
          where gifts.id in (#{engine.gift_scope.select(:id).to_sql})
        }
      end
    end
  end
end