module Admin
  class UserImportsController < BaseController
    def new
      @user_import = UserImport.new
    end

    def create
      @user_import = UserImport.new user_import_params
      if @user_import.save_records && @user_import.row_errors.none?
        flash.notice = "Invitations sent to #{@user_import.users_created_count} new users."
        redirect_to admin_users_path
      else
        flash.alert = "There was a problem with the import. Invitations sent to #{@user_import.users_created_count} new users."
        render :new
      end
    end

    def user_import_params
      params.require(:user_import).permit(
        :records_file
      )  
    end

    def active_top_nav_section
      'users'
    end
    helper_method :active_top_nav_section

  end
end
