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
        
        if @unsorted_gift_scores.any?
          load_categories
          build_bags
          sort_bags
          sort_gift_scores
        end
        
        @gift_scores
      end
      
      protected
      
      def load_categories
        # build a map between gifts and a single product subcategory
        map = {}
        gift_ids = @unsorted_gift_scores.map{|_| _[:id]}
        sql = %{
          select g.id, g.product_subcategory_id as category_id
          from gifts as g
          where g.id in (#{gift_ids.join(',')})
        }
        rows = Gift.connection.select_rows(sql)
        rows.each {|_| map[_[0].to_i] = _[1].to_i}
        
        # add the category to the gift scores
        @unsorted_gift_scores.each {|_| _[:category_id] = map[_[:id]]}
      end
      
      def build_bags
        # create bags of gifts by category with some stats for each bag
        @unsorted_gift_scores.group_by{|_| _[:category_id]}.each do |category_id, bag_gift_scores|
          bag_gift_scores.sort!{|a, b| b[:score] <=> a[:score]}
          scores = bag_gift_scores.map{|_| _[:score]}
          @bags << {
            category_id:  category_id,
            max_score:    scores.max,
            avg_score:    scores.sum.to_f / bag_gift_scores.count,
            gift_scores:  bag_gift_scores
          }
        end
      end
      
      def sort_gift_scores
        # interleave the gifts from each category bag. The bags are sorted by score.
        bag_gift_scores = @bags.map{|_| _[:gift_scores].dup}
        
        while (bag_gift_scores = bag_gift_scores.select(&:any?)).any?
          # take the first gift_score from each remaining bag
          @gift_scores += bag_gift_scores.map(&:shift)
        end
      end
      
      def sort_bags
        # descending order by max_score and avg_score
        @bags.sort!{|a, b| [b[:max_score], b[:avg_score]] <=> [a[:max_score], a[:avg_score]]}
      end
    end
  end
end
 