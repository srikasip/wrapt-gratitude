module Admin
  class CommentsController < BaseController
    def create
      comment = Comment.new(permitted_params)
      comment.user = current_user
      if !comment.save
        flash[:error] = 'There was a problem saving'
      end
      redirect_back fallback_location: root_path
    end

    def require_login?
      true
    end

    private def permitted_params
      params.require(:comment).permit( :content, :commentable_id, :commentable_type)
    end
  end
end
