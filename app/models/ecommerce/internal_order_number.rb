# This is a wrapper on a postgres sequence.  It provides a way to get globally
# unique values, so that purchase orders and orders never can get the same
# values

class InternalOrderNumber
  RANGE = 0..999_000_000_000

  def self.next_val
    ApplicationRecord.connection.execute(<<-SQL).values.first.first.to_i
      select nextval('internal_order_numbers') AS value
    SQL
  end

  def self.next_val_humanized
    humanize(self.next_val)
  end

  def self.humanize(number)
    str = number. # 71
      to_s(18).   # "3h"
      upcase      # "3H"

    "0000000000000#{str}". # 00000000000003H
      reverse.             # H30000000000000
      each_char.           # ['H', '3', ... ]
      each_slice(3).       # [['H', '3', '0'], []...]
      to_a.
      first(3).
      map { |x| x.join }.
      join('-').
      reverse
  end
end
