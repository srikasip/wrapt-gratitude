require 'csv'

class ProductsExportJob < ApplicationJob
  RecordConf = Struct.new(:label, :getter)

  queue_as :default

  attr_reader :params

  def perform(params)
    @params = params
    _build_and_upload_csv
    _broadcast!
  end

  private

  def _build_and_upload_csv
    _with_csv_handle do |csv|
      csv << _record_conf.map(&:label)

      Product.find_each do |product|
        csv << _record_conf.map { |rc| rc.getter.(product) }
      end

      csv.flush

      @export = FileExport.new
      @export.asset = csv
      @export.asset_type = 'products'
      @export.user_id = params['user_id']
      @export.save!
    end
  end

  def _broadcast!
    ActionCable.server.broadcast(
      "file_exports_#{params['user_id']}",
      url: @export.asset.url
    )
  end

  def _record_conf
    [
      RecordConf.new('Title',           ->(p) { p.title }),
      RecordConf.new('Description',     ->(p) { p.description }),
      RecordConf.new('Category',        ->(p) { p.product_category&.name }),
      RecordConf.new('Wrapt SKU',       ->(p) { p.wrapt_sku }),
      RecordConf.new('Vendor SKU',      ->(p) { p.vendor_sku }),
      RecordConf.new('Gifts',           ->(p) { p.gifts.map(&:name).join('; ') }),
      RecordConf.new('Price ($)',       ->(p) { p.price }),
      RecordConf.new('Wrapt Cost ($)',  ->(p) { p.wrapt_cost }),
      RecordConf.new('Vendor',          ->(p) { p.vendor&.name }),
      RecordConf.new('Units Available', ->(p) { p.units_available }),
      RecordConf.new('Weight (lb)',     ->(p) { p.weight_in_pounds }),
      RecordConf.new('Notes',           ->(p) { p.notes })
    ]
  end

  def _with_csv_handle
    tempfile = Tempfile.new(['products.', '.csv'])
    path = tempfile.path
    CSV.open(path, 'w') do |csv|
      yield csv
    end
    tempfile.unlink
  end
end
