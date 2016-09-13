module LoadsTestData
  extend ActiveSupport::Concern

  def setup
    super
    @test_data = TestData.new
    @test_data.load_data!
  end

  def teardown
    @test_data.cleanup!
  end

end