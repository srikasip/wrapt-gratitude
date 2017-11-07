module Ec
  module Tax
    COMPANY = ENV.fetch('AVATAX_COMPANY') { 'DEFAULT' }

    def self.table_name_prefix
      'tax_'
    end
  end
end
