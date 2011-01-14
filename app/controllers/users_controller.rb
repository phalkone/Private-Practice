class UsersController < ApplicationController
  before_filter :admin, :only => [:roles,:update_roles]
  before_filter :admin_doctor, :only => [:index,:destroy]
  before_filter :logged_in, :only => [:edit,:update,:show]
  before_filter :correct_user, :only => [:edit,:update,:show]
    
  def index
    @users = User.order("last_name ASC").all.paginate :page => params[:page], :per_page => 10
    @title = t("users.menutitle")
  end

  def new
    @user = User.new
    @title = t("users.newtitle")
    @submit_text = t("users.submit.new");
  end

  def refresh
    if params[:term] != t('users.search')
      @users = User.where(search_term(params[:term])).order("last_name ASC").all.paginate :page => params[:page], :per_page => 10
    else
      @users = User.order("last_name ASC").all.paginate :page => params[:page], :per_page => 10
    end
  end

  def search
    @users = User.where(search_term(params[:term])).order("last_name ASC").all.paginate :page => params[:page], :per_page => 10
    render "refresh"
  end

  def autocomplete
    @results = User.where(search_term(params[:term])).all
    result = Array.new
    @results.each() do |user|
      result.insert(-1,user.name)
    end
    render :json => result.to_json
  end

  def delete_selected
    if params[:selected] && User.destroy(params[:delete].split(";"))
      flash[:alert] = t("users.sel_destroyed")
      params[:selected].split(";").each do |id|
        if apps = Appointment.where("patient_id = ?",id)
          apps.each() do |app|
            app.unbook
          end
        end
      end
    end
    @users = User.order("last_name ASC").all.paginate :page => params[:page], :per_page => 10
    render "refresh"
  end

  def create
    params[:user][:super_reg] = "1" if (role?("admin") || role?("doctor"))
    @user = User.new(params[:user])
    if params[:commit][t("users.submit.cancel")]
      if (role?("admin") || role?("doctor"))
        redirect_to users_path
      else
        redirect_to root_path
      end
    else
      if @user.save
        sign_in @user unless role?("admin") || role?("doctor")
        flash[:notice] = t("users.created")
        redirect_to @user
      else
        @title = t("users.newtitle")
        @submit_text = t("users.submit.new");
        render 'new'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @title = t("users.edittitle")
    @submit_text = t("users.submit.edit");
  end

   def update
    @user = User.find(params[:id])
    if params[:commit][t("users.submit.cancel")]
      redirect_to @user
    else
      params[:user][:super_reg] = "1" if (role?("admin") || role?("doctor"))
      if @user.update_attributes(params[:user])
        sign_in @user unless role?("admin") || role?("doctor")
        flash[:notice] = t("users.edited")
        redirect_to @user
      else
        @title = t("users.edittitle")
        @submit_text = t("users.submit.edit");
        render 'edit'
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:alert] = t("users.destroyed")
      if apps = Appointment.where("patient_id = ?",params[:id].to_i)
        apps.each() do |app|
          app.unbook
        end
      end
    end
    @users = User.order("last_name ASC").all.paginate :page => params[:page], :per_page => 10
    render "refresh"
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def roles
    @user = User.find(params[:id])
    @title = @user.name
  end

  def update_roles
    @user = User.find(params[:id])
    if params[:commit][t("users.submit.cancel")]
      redirect_to @user
    else
      @user.roles.clear
      if params[:role]
        params[:role].each do |role_id, on|
          @user.roles << Role.find(role_id)
        end
      end
      redirect_to @user
    end
  end

  private
    def search_term(params_term)
      search_split = params_term.split(" ")
      search_t = ""
      search_split.each() do |term|
        search_t += "(first_name LIKE '"+term+"%' OR last_name LIKE '"+term+"%')"
        search_t+= " AND " unless (term == search_split.last) 
      end
      return search_t
    end

    def admin
      deny_access unless role?("admin")
    end

    def admin_doctor
      deny_access unless role?("admin") || role?("doctor")
    end

    def logged_in
      deny_access unless signed_in?
    end

    def correct_user
     @user = User.find(params[:id])
     redirect_to(root_path) unless current_user?(@user) || role?("admin") || role?("doctor")
    end

end
