class UsersController < ApplicationController
  before_filter :admin_only, :only => [:admin, :update_admin]
  before_filter :admin_doctor, :only => [:index,:destroy]
  before_filter :logged_in, :only => [:edit,:update,:show,:message]
  before_filter :correct_user, :only => [:edit,:update,:show]
  before_filter :correct_doctor, :only => [:messages,:edit,:update,:show]
  before_filter :set_sort, :only => [:index,:refresh,:search,:autocomplete,
    :delete_selected,:destroy]
  
  def index
    if role?("admin")
      @users = User.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    else
      @users = Role.where("title = ?","patient").first.users.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    end
    @title = t("users.menutitle")
  end

  def new
    @user = User.new
    @title = t("users.newtitle")
    @submit_text = t("users.submit.new");
  end

  def refresh
    @div ||= "#users_table"
    @partial ||= "table"
    if params[:term] && params[:term] != t('users.search')
      if role?("admin")
        @users = User.where(search_term(params[:term])).order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
      else
        @users = Role.where("title = ?","patient").first.users.where(search_term(params[:term])).order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
      end
    else
      if role?("admin")
        @users = User.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
      else
        @users = Role.where("title = ?","patient").first.users.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
      end
    end
  end

  def search
    if role?("admin")
      @users = User.where(search_term(params[:term])).order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    else
      @users = Role.where("title = ?","patient").first.users.where(search_term(params[:term])).order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    end
    @div = "#users_table"
    @partial = "table"
    render "refresh"
  end

  def autocomplete
    @results = User.where(search_term(params[:term])).all
    if role?("admin")
      @results = User.where(search_term(params[:term])).order(cookies[:sort]).all
    else
      @results = Role.where("title = ?","patient").first.users.where(search_term(params[:term])).order(cookies[:sort]).all
    end
    result = Array.new
    @results.each() do |user|
      result.insert(-1,user.last_name + " " + user.first_name)
    end
    render :json => result.to_json
  end

  def delete_selected
    if params[:selected] && User.destroy(params[:selected].split(";"))
      flash.now[:alert] = t("users.sel_destroyed")
      params[:selected].split(";").each do |id|
        if apps = Appointment.where("patient_id = ?",id)
          apps.each() do |app|
            app.unbook
          end
        end
      end
    end
    if role?("admin")
      @users = User.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    else
      @users = Role.where("title = ?","patient").first.users.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    end
    @div = "#users_table"
    @partial = "table"
    render "refresh"
  end

  def create
    @user = User.new(params[:user])
    @user.super_reg = (role?("admin") || role?("doctor"))
    if params[:commit][t("users.submit.cancel")]
      if (role?("admin") || role?("doctor"))
        redirect_to users_path
      else
        redirect_to root_path
      end
    else
      if @user.save
        flash[:success] = t("users.created")
        if (role?("admin") || role?("doctor"))
          redirect_to @user
        else
          @user.deliver_email_confirmation_instructions
          redirect_to root_path
        end
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
      @user.super_reg = (role?("admin") || role?("doctor"))
      if @user.update_attributes(params[:user])
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
      flash.now[:alert] = t("users.destroyed")
    end
    if role?("admin")
      @users = User.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    else
      @users = Role.where("title = ?","patient").first.users.order(cookies[:sort]).all.paginate :page => params[:page], :per_page => 10
    end
    @div = "#users_table"
    @partial = "table"
    render "refresh"
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
    @menu_active = "profile" if (@user.id == current_user.id)
  end
  
  def contact_info
    @user = User.find(params[:id])
    @title = @user.name
    @menu_active = "profile" if (@user.id == current_user.id)
  end
  
  def edit_contact_info
    @user = User.find(params[:id])
    @title = @user.name
    @menu_active = "profile" if (@user.id == current_user.id)
  end
  
  def admin
    @user = User.find(params[:id])
    @title = @user.name
    @menu_active = "profile" if (@user.id == current_user.id)
  end
  
  def update_admin
    @user = User.find(params[:id])
    case params[:clicked]
      when "confirmed" then @user.update_attribute("confirmed", params[:set])
      when "active" then @user.update_attribute("active", params[:set])
      when "send_confirmation" then 
        @user.deliver_email_confirmation_instructions
        flash.now[:notice] = t("email_confirmations.flash_request")
      when "send_reset" then
        @user.deliver_password_reset_instructions
        flash.now[:notice] = t("password_resets.flash_success")
      when "delete" then
        if @user.destroy
          flash[:alert] = t("users.destroyed")
          render :update do |page|
            page << 'window.location = "' + users_url  + '";'
          end
          return
        end
      else
        role = Role.find_by_title(params[:clicked])
        if params[:set] == "true"
          @user.roles << role unless @user.roles.include? role
        elsif @user.roles.count != 1
          @user.roles.delete(role) unless !@user.roles.include?(role)
        elsif @user.roles.include?(role)
          flash.now[:error] = t("users.one_role")
        end
    end
    @div = "#admin"
    @partial = "admin"
    render "refresh"
  end
  
  def messages
    @user = User.find(params[:id])
    @title = @user.name
    @menu_active = "profile" if (@user.id == current_user.id)
    @messages = @user.messages.order("created_at DESC").paginate :page => params[:page], :per_page => 10
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

    def admin_only
      deny_access unless role?("admin")
    end

    def admin_doctor
      deny_access unless role?("admin") || role?("doctor")
    end

    def logged_in
      deny_access unless signed_in?
    end
    
    def correct_doctor
      @user = User.find(params[:id])
      deny_access unless current_user?(@user) || role?("admin")
    end

    def correct_user
     @user = User.find(params[:id])
     deny_access unless current_user?(@user) || role?("admin") || role?("doctor")
    end
    
    def set_sort
      if params[:sort]
        cookies.permanent[:sort] = { :value => params[:sort], :domain => request.domain }
      elsif !cookies[:sort]
        cookies.permanent[:sort] = { :value => "last_name ASC", :domain => request.domain }
      end
    end

end
