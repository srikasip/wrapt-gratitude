module Recommender
  module Scoring
    class TagBoost < Base
      attr_reader :boost, :tag_names
      
      def load_params
        @boost = 1
        @tag_names = collect_tag_names(find_params('boost_tags'))
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