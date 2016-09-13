require 'test_helper'

class ProductsTest < ActionDispatch::IntegrationTest
  include IntegrationTestAuthenticator
  include LoadsTestData

  def setup
    super
    log_in_as_admin!
  end

  def test_index
    visit '/products'
    assert page.has_content? 'Add a Product'
  end

  def test_new
    visit '/products/new'
    assert page.has_content? 'New Product'
  end

  def test_show
    visit "/products/#{Product.first.id}"
    assert page.has_content? Product.first.title
  end



end
