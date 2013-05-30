class UsersController < ApplicationController
  respond_to :html, :js
  responders :flash, :http_cache
  before_filter :authenticate_user!
  before_filter :dont_delete_yourself, only: :destroy
  before_filter :only_change_own_password, only: [:change_password, :update_password]
  skip_before_filter :set_password, only: [:change_password, :update_password]

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def new
    @user = User.new
    respond_with @user
  end

  def edit
    @user = User.find(params[:id])
    respond_with @user
  end

  def change_password
    @user = User.find(params[:id])
    respond_with @user
  end

  def create
    @user = User.new(params[:user])
    @user.save
    respond_with @user
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    respond_with @user
  end

  def update_password
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      sign_in(@user, bypass: true) if @user == current_user
      redirect_to welcome_index_path
    else
      render :change_password
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_with @user
  end

  protected
  def dont_delete_yourself
    return unless params[:id].to_i == current_user.id
    redirect_to users_path, alert: t('flash.error.cant_delete_yourself')
  end

  def only_change_own_password
    return if params[:id] == current_user.to_param
    redirect_to welcome_index_path
  end
end
