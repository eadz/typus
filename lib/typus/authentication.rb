module Authentication

  protected

    # Before doing nothing on Typus require_login
    def require_login
      redirect_to :controller => 'typus', :action => 'login' if !session[:typus]
    end

    # Check if the user is logged on the system.
    def logged_in?
      return false unless session[:typus]
      begin
        @current_user ||= TypusUser.find(session[:typus])
      rescue ActiveRecord::RecordNotFound
        session[:typus] = nil
      end
    end

    # Return the current user
    def current_user
      @current_user if logged_in?
    end

    # Before filter to limit certain actions to administrators
    def require_admin
      unless admin?
        flash[:notice] = "Sorry, only administrators can do that."
        redirect_to :controller => 'typus', :action => 'dashboard'
      end
    end

    # Helper method to determine whether the current user is an administrator
    def admin?
      current_user.admin?
    end

    # Determine if the user can edit/modify the current record
    def can_edit? record
      return true if current_user.admin?
      case record.class.to_s
      when 'TypusUser' # regular users can't edit other users
        record.id == current_user.id
      #when 'Message'
        # messages can only be edited by their creators
        # record.created_by == current_user.id
      else # everyone can edit anything else
        true
      end
    end

    # Determine if the user can edit/modify the current record
    def can_add? record
      return true if current_user.admin?
      case record.class.to_s
      when 'TypusUser' # regular users can't edit other users
        false # true # record.id == current_user.id
      #when 'Message'
        # messages can only be edited by their creators
        # record.created_by == current_user.id
      else # everyone can edit anything else
        true
      end
    end

    def generate_password(length=8)
      chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      password = ""
      1.upto(length) { |i| password << chars[rand(chars.size - 1)] }
      puts password
      return password
    end

end