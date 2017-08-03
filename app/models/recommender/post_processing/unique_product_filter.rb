module Recommender
  module PostProcessing
    class UniqueProductFilter
      attr_reader :gift_scores, :min_total
      
      def initialize(gift_scores, min_total)
        @unfiltered_gift_scores = gift_scores
        @min_total = min_total
      end
      
      def filter
        @gift_scores = []
        if @unfiltered_gift_scores.any?
          load_products
          remove_duplicates
        end
        @gift_scores
      end
      
      protected
      
      def load_products
        # build a map between gifts and a single product subcategory
        map = {}
        gift_ids = @unfiltered_gift_scores.map{|_| _[:id]}
        sql = %{
          select g.id, gp.product_id
          from gifts as g
          join gift_products as gp on g.id = gp.gift_id
          where g.id in (#{gift_ids.join(',')})
        }
        rows = Gift.connection.select_rows(sql)
        rows.each {|_| (map[_[0].to_i] ||= []) << _[1].to_i}
        
        # add the category to the gift scores
        @unfiltered_gift_scores.each {|_| _[:product_ids] = map[_[:id]]}
      end
      
      def remove_duplicates
        product_ids = []
        duplicate_gift_scores = []
        @unfiltered_gift_scores.each do |gift_score|
          if (gift_score[:product_ids] && product_ids).any?
            duplicate_gift_scores << gift_score
          end
          product_ids += gift_score[:product_ids]
        end
        max_allowed_to_remove = [@unfiltered_gift_scores.length - min_total, 0].max
        duplicate_gift_scores = duplicate_gift_scores.reverse.take(max_allowed_to_remove)
        @gift_scores = @unfiltered_gift_scores - duplicate_gift_scores
      end
    end
  end
end
