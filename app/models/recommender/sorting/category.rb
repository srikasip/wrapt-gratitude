module Recommender
  module Sorting
    class CategorySort
      attr_reader :gift_scores
      
      def initialize(gift_scores)
        @unsorted_gift_scores = gift_scores
      end
      
      def sort
        @gift_scores = []
        @gift_categories = {}
        @bags = []
        
        load_categories
        build_bags
        sort_bags
        sort_gift_scores
        
        @gift_scores
      end
      
      protected
      
      def load_categories
        # build a map between gifts and a single product subcategory
        map = {}
        gift_ids = @gift_scores.map{|_| _[:id]}
        sql = %{
          select g.id, max(pc.id)
          from gifts as g
          join gift_products as gp on g.id = gp.gift_id
          join products as p on gp.product_id = p.id
          join product_categories as pc on p.product_subcategory_id = pc.id
          where g.id in (#{gift_ids.join(',')})
          group by g.id
        }
        rows = Gift.connection.select_rows(sql)
        rows.each {|_| map[_[0].to_i] = _[1].to_i}
        
        # add the category to the gift scores
        @gift_scores.each {|_| _[:category_id] = map[_[:id]]}
      end
      
      def build_bags
        # create bags of gifts by category with some stats for each bag
        @gift_scores.group_by{|_| _[:category_id]}.each do |category_id, bag_scores|
          scores = bag_scores.map{|_| _[:score]}
          @bags << {
            category_id:  category_id,
            max_score:    scores.max,
            avg_score:    scores.sum.to_f / bag_scores.count,
            gift_scores:  bag_scores
          }
        end
      end
      
      def sort_gift_scores
        # interleave the gifts from each category bag
        @gift_scores = @bags.map{|_| _[:gift_scores]}.zip
      end
      
      def sort_bags
        # descending order by max_score and avg_score
        @bag.sort!{|a, b| [b[:max_score], b[:avg_score]] <=> [a[:max_score], a[:avg_score]]}
      end
    end
  end
end
 