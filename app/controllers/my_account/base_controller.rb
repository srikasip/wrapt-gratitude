class MyAccount::BaseController < ApplicationController
  before_action -> { @show_account_sub_nav=true }
end
