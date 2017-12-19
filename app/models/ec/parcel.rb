module Ec
  class Parcel < ApplicationRecord
    USAGE_TYPES = [
      PRETTY= 'pretty',
      SHIPPING = 'shipping'
    ]

    TEMPLATES = [
      'USPS_SmallFlatRateBox',
      'USPS_MediumFlatRateBox1',
      'USPS_MediumFlatRateBox2',
      'USPS_FlatRateEnvelope',
      'USPS_FlatRateCardboardEnvelope'
    ]

    validates :description,      presence: true
    validates :code,             presence: true, uniqueness: true
    validates :case_pack, numericality: { only_integer: true }, allow_nil: true
    validates :height_in_inches, numericality: { greater_than: 0 }
    validates :height_in_inches, presence: true
    validates :length_in_inches, numericality: { greater_than: 0 }
    validates :length_in_inches, presence: true
    validates :weight_in_pounds, numericality: { greater_than: 0 }
    validates :weight_in_pounds, presence: true
    validates :width_in_inches,  numericality: { greater_than: 0 }
    validates :width_in_inches,  presence: true
    validates :usage, inclusion: { in: USAGE_TYPES, message: "must be either #{USAGE_TYPES.first} or #{USAGE_TYPES.last}" }
    validates :shippo_template_name, inclusion: { in: TEMPLATES }, allow_nil: true, allow_blank: true

    scope :active,    -> { where(active: true) }
    scope :inactive,  -> { where(active: false) }
    scope :pretty,    -> { where(usage: PRETTY) }
    scope :shipping,  -> { where(usage: SHIPPING) }
    scope :by_weight, -> { order(:weight_in_pounds) }

    def as_shippo_hash
      {
        length:        self.length_in_inches,
        width:         self.width_in_inches,
        height:        self.height_in_inches,
        distance_unit: :in,
        weight:        self.weight_in_pounds,
        mass_unit:     :lb
      }.tap do |shippo_hash|
        if shippo_template_name.present?
          shippo_hash[:template] = shippo_template_name
        end
      end
    end
  end
end

=begin

Other template parcels

FedEx_Box_10kg	Box 10kg	15.81 x 12.94 x 10.19 in
FedEx_Box_25kg	Box 25kg	54.80 x 42.10 x 33.50 in
FedEx_Box_Extra_Large_1	Box Extra Large (1)	11.88 x 11.00 x 10.75 in
FedEx_Box_Extra_Large_2	Box Extra Large (2)	15.75 x 14.13 x 6.00 in
FedEx_Box_Large_1	Box Large (1)	17.50 x 12.38 x 3.00 in
FedEx_Box_Large_2	Box Large (2)	11.25 x 8.75 x 7.75 in
FedEx_Box_Medium_1	Box Medium (1)	13.25 x 11.50 x 2.38 in
FedEx_Box_Medium_2	Box Medium (2)	11.25 x 8.75 x 4.38 in
FedEx_Box_Small_1	Box Small (1)	12.38 x 10.88 x 1.50 in
FedEx_Box_Small_2	Box Small (2)	11.25 x 8.75 x 4.38 in
FedEx_Envelope	Envelope	12.50 x 9.50 x 0.80 in
FedEx_Padded_Pak	Padded Pak	11.75 x 14.75 x 2.00 in
FedEx_Pak_1	Pak (1)	15.50 x 12.00 x 0.80 in
FedEx_Pak_2	Pak (2)	12.75 x 10.25 x 0.80 in
FedEx_Tube	Tube	38.00 x 6.00 x 6.00 in
FedEx_XL_Pak	XL Pak	17.50 x 20.75 x 2.00 in

UPS_Box_10kg	Box 10kg	410.00 x 335.00 x 265.00 mm
UPS_Box_25kg	Box 25kg	484.00 x 433.00 x 350.00 mm
UPS_Express_Box	Express Box	460.00 x 315.00 x 95.00 mm
UPS_Express_Box_Large	Express Box Large	18.00 x 13.00 x 3.00 in
UPS_Express_Box_Medium	Express Box Medium	15.00 x 11.00 x 3.00 in
UPS_Express_Box_Small	Express Box Small	13.00 x 11.00 x 2.00 in
UPS_Express_Envelope	Express Envelope	12.50 x 9.50 x 2.00 in
UPS_Express_Hard_Pak	Express Hard Pak	14.75 x 11.50 x 2.00 in
UPS_Express_Legal_Envelope	Express Legal Envelope	15.00 x 9.50 x 2.00 in
UPS_Express_Pak	Express Pak	16.00 x 12.75 x 2.00 in
UPS_Express_Tube	Express Tube	970.00 x 190.00 x 165.00 mm
UPS_Laboratory_Pak	Laboratory Pak	17.25 x 12.75 x 2.00 in
UPS_MI_BPM	BPM (Mail Innovations - Domestic & International)	0.00 x 0.00 x 0.00 in
UPS_MI_BPM_Flat	BPM Flat (Mail Innovations - Domestic & International)	0.00 x 0.00 x 0.00 in
UPS_MI_BPM_Parcel	BPM Parcel (Mail Innovations - Domestic & International)	0.00 x 0.00 x 0.00 in
UPS_MI_First_Class	First Class (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_Flat	Flat (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_Irregular	Irregular (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_Machinable	Machinable (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_MEDIA_MAIL	Media Mail (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_Parcel_Post	Parcel Post (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_Priority	Priority (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_MI_Standard_Flat	Standard Flat (Mail Innovations - Domestic only)	0.00 x 0.00 x 0.00 in
UPS_Pad_Pak	Pad Pak	14.75 x 11.00 x 2.00 in
UPS_Pallet	Pallet	120.00 x 80.00 x 200.00 cm


USPS_FlatRateCardboardEnvelope	Flat Rate Cardboard Envelope	12.50 x 9.50 x 0.75 in
USPS_FlatRateEnvelope	Flat Rate Envelope	12.50 x 9.50 x 0.75 in
USPS_FlatRateGiftCardEnvelope	Flat Rate Gift Card Envelope	10.00 x 7.00 x 0.75 in
USPS_FlatRateLegalEnvelope	Flat Rate Legal Envelope	15.00 x 9.50 x 0.75 in
USPS_FlatRatePaddedEnvelope	Flat Rate Padded Envelope	12.50 x 9.50 x 1.00 in
USPS_FlatRateWindowEnvelope	Flat Rate Window Envelope	10.00 x 5.00 x 0.75 in
USPS_IrregularParcel	Irregular Parcel	0.00 x 0.00 x 0.00 in
USPS_LargeFlatRateBoardGameBox	Large Flat Rate Board Game Box	24.06 x 11.88 x 3.13 in
USPS_LargeFlatRateBox	Large Flat Rate Box	12.25 x 12.25 x 6.00 in
USPS_APOFlatRateBox	APO/FPO/DPO Large Flat Rate Box	12.25 x 12.25 x 6.00 in
USPS_LargeVideoFlatRateBox	Flat Rate Large Video Box (Int'l only)	9.60 x 6.40 x 2.20 in
USPS_MediumFlatRateBox1	Medium Flat Rate Box 1	11.25 x 8.75 x 6.00 in
USPS_MediumFlatRateBox2	Medium Flat Rate Box 2	14.00 x 12.00 x 3.50 in
USPS_RegionalRateBoxA1	Regional Rate Box A1	10.13 x 7.13 x 5.00 in
USPS_RegionalRateBoxA2	Regional Rate Box A2	13.06 x 11.06 x 2.50 in
USPS_RegionalRateBoxB1	Regional Rate Box B1	12.25 x 10.50 x 5.50 in
USPS_RegionalRateBoxB2	Regional Rate Box B2	16.25 x 14.50 x 3.00 in
USPS_SmallFlatRateBox	Small Flat Rate Box	8.69 x 5.44 x 1.75 in
USPS_SmallFlatRateEnvelope	Small Flat Rate Envelope	10.00 x 6.00 x 4.00 in
USPS_SoftPack	Soft Pack Padded Envelope	Length and width defined in the Parcel

=end
