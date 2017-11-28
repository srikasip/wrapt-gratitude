module Recommender
  module PostProcessing
    class DistributedSort
      attr_reader :gift_scores
      
      def initialize(gift_scores)
        @unsorted_gift_scores = gift_scores
      end
      
      def sort
        @gift_scores = []
        
        if @unsorted_gift_scores.any?
          load_categories
          load_vendors
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
      
      def load_vendors
        # build a map between gifts and a single vendor
        map = {}
        gift_ids = @unsorted_gift_scores.map{|_| _[:id]}
        sql = %{
          select g.id, max(p.vendor_id) as vendor_id
          from gifts as g
          join gift_products as gp on gp.gift_id = g.id
          join products as p on gp.product_id = p.id
          where g.id in (#{gift_ids.join(',')})
          group by g.id
        }
        rows = Gift.connection.select_rows(sql)
        rows.each {|_| map[_[0].to_i] = _[1].to_i}
        
        # add the category to the gift scores
        @unsorted_gift_scores.each {|_| _[:vendor_id] = map[_[:id]]}
      end
      
      
      def sort_gift_scores
        # sort the gifts by score and distribute them by vendor and category
        available_gift_scores = @unsorted_gift_scores.dup
        available_gift_scores.sort!{|a, b| b[:score] <=> a[:score]}

        vendor_counts = {}
        category_counts = {}
        
        # loop though the gifts adding only one gift from each vendor or category
        # in each pass until they have all been added to the output array.
        while available_gift_scores.any?
          
          skip_vendor_ids = Set.new
          skip_category_ids = Set.new
          
          available_gift_scores.reject! do |gift_score|
            vendor_id = gift_score[:vendor_id]
            category_id = gift_score[:category_id]
            
            vendor_count = vendor_counts[vendor_id].to_i
            category_count = category_counts[category_id].to_i
            
            if skip_vendor_ids.include?(vendor_id) || skip_category_ids.include?(category_id)
              # penalize gifts that are similar to those in the output array
              gift_score[:adjusted_score] = gift_score[:score] - vendor_count - category_count
              # keep this gift in the available list for the next pass
              false
            else
              # add it the output array and remove it from the available list
              @gift_scores << gift_score
              skip_vendor_ids << vendor_id
              skip_category_ids << category_id
              vendor_counts[vendor_id] = vendor_count + 1
              category_counts[vendor_id] = category_count + 1
              true
            end
          end
          
          # re-sort the list based on the adjusted scores before the next pass
          available_gift_scores.sort!{|a, b| b[:adjusted_score] <=> a[:adjusted_score]}
        end
      end
      
    end
  end
end
 