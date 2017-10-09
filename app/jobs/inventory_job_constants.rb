module InventoryJobConstants
  Column = Struct.new(:title, :column_matcher, :writable, :getter)

  COLUMN_DATA = [
    Column.new('Supplier Product SKU', /Supplier Product SKU/ , false , 'vendor_sku'),
    Column.new('Wrapt Product SKU'   , /Wrapt Product SKU/    , false , 'wrapt_sku'),
    Column.new('Description'         , /Description/          , true  , 'description'),
    Column.new('Inventory Count'     , /Inventory Count/      , true  , 'units_available'),
    Column.new('Price'               , /Price/                , true  , 'price')
  ]

  WRITABLE_COLUMNS = COLUMN_DATA.select(&:writable).map(&:getter)

  WRITABLE_COLUMNS_HUMAN = COLUMN_DATA.select(&:writable).map(&:title)

  CSV_CONFIG = {
    headers: true,
    header_converters: [
      -> (field, _) {
        result = COLUMN_DATA.find { |x| x.column_matcher.match(field) }.try(:getter)
        result ||= field.downcase.gsub(/ /, '_')
      }
    ]
  }.freeze
end
