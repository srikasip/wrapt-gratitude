//= require ./namespace

App.Admin.ProductSubcategoryLoader = class ProductSubcategoryLoader {
  constructor(options = {}) {
    this.prompt = (options.prompt || "");
    this.formElement = $('[data-behavior~=form-loads-subcategories]')[0];
    this.productCategoryInput = $(this.formElement).find('[data-behavior~=product-category-input]')[0]
    this.productSubCategoryInput = $(this.formElement).find('[data-behavior~=product-subcategory-input]')[0]

    console.log(this.formElement, this.productCategoryInput, this.productSubCategoryInput)

    $(this.productCategoryInput).on('change', evt => {
      const productCategoryId = $(this.productCategoryInput).val()
      if (productCategoryId) {
        $(this.productSubCategoryInput).load(`/product_categories/${productCategoryId}/subcategories?prompt=${this.prompt}`)
      }
    })
  }

}