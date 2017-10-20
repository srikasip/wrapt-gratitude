class MyAccount::BaseController < ApplicationController
  before_action -> { @show_account_sub_nav=true }
  before_action -> { @enable_chat = true }
end
