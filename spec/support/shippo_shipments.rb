module ShippoShipments
  def shipment
    @shipment ||= \
      Shipment.new({
        address_to: {
          name: 'Todd Blackman',
          street1: '319 Hague Rd',
          city: 'Dummerston',
          zip: '05301',
          state: 'VT',
          country: 'US',
          phone:  '802-123-1234',
          email: 'example@example.com',
        },
        address_from: {
          name: 'Kristy Blackman',
          street1: '14321 Norwood',
          city: 'Leawood',
          zip: '66224',
          state: 'KS',
          country: 'US',
          phone:  '913-123-1234',
          email: 'example@example.com',
        },
        parcel: {
          length: 4,
          width: 4,
          height: 4,
          distance_unit: :in,
          weight:  1.5,
          mass_unit: :lb
        }
      })
  end
end
