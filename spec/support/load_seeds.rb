RSpec.configure do |c|
  c.before(:suite) do
    load 'db/seeds.rb'
  end
end
