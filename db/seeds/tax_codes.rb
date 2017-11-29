tax_codes = [
  { code: 'P0000000', name: 'Generic', description: "Tangible personal property is generally deemed to be items, other than real property (e.g. land and buildings), that are tangible in nature. The presumption of taxability is on all items of TPP unless specifically made non-taxable by individual state and/or local statutes. This system tax code can be used when no other specific system tax code is applicable or available. Additionally, this system tax code has a taxable default associated with it and consequently the user could use this code for any and all products that are known to be taxable and if they want to limit the number of system tax codes being used." },
  { code: 'FR000000', name: 'Generic Freight', description: "Charges for delivery, shipping, or shipping and handling. These charges represent the cost of the transportation of product sold to the customer, and if applicable, any special charges for handling or preparing the product for shipping. These separately identified charges are paid to the seller of the goods and not to the shipping company." },
  { code: 'PC040206', name: 'Jewelry', description: "Clothing & related products (B2C) - Jewelry" },
  { code: 'WT000001', name: 'Wrapt Gift', description: "Custom tax code for wrapt gifts" },
  { code: 'PG081610', name: 'Food Only Gift', description: "Mixed Products and Baskets Wherein Exempt Items Constitute 90% to 100% of the Total Value of the Basket or Container (e.g. Fruit Baskets)" }
]

tax_codes.each do |data|
  tax_code = Ec::Tax::Code.where(code: data[:code]).first_or_initialize
  tax_code.assign_attributes(data)
  tax_code.save!
end
