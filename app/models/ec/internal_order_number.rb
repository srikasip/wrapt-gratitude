# This is a wrapper on a postgres sequence.  It provides a way to get globally
# unique values, so that purchase orders and orders never can get the same
# values

module Ec
  class InternalOrderNumber
    RANGE  = 0..999_000_000_000
    LOOKUP = ("A".."Z").to_a + ("1".."9").to_a + ("a".."z").to_a

    def self.next_val
      raw_number = ApplicationRecord.connection.execute(<<-SQL).values.first.first.to_i
        select nextval('internal_order_numbers') AS value
      SQL

      # Ensure we have digits in the 1000s place or higher
      raw_number *= 1000
    end

    def self.next_customer_order_number
      'WRAPT-' + humanize(self.next_val)
    end

    def self.make_purchase_order_number(customer_order_number, index)
      raise "Too many purchase orders!" if index > LOOKUP.length-1

      template = customer_order_number.dup
      template.sub!(/WRAPT/, 'PO')
      template[-1] = LOOKUP[index]

      template
    end

    def self.humanize(number)
      str = number.to_s

      "0000000000000#{str}". # 000000000000031
        reverse.             # 130000000000000
        each_char.           # ['1', '3', ... ]
        each_slice(3).       # [['1', '3', '0'], []...]
        to_a.
        first(3).
        map { |x| x.join }.
        join('-').
        reverse
    end
  end
end
