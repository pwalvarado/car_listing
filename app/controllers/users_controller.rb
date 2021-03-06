class UsersController < ApplicationController
  before_filter :set_singular_resource, only:
    [:show, :edit, :update, :destroy]

  before_filter :require_user_signed_in, only: [:dashboard]

  before_filter :require_owner, only:
    [:edit, :update, :destroy, :change_email]



  def new
    @user = User.new
  end

  def show
    if @user.is_activated?
      # rendering a partial in the :show with formats: [:json], which sets the
      # response to Content-Type="application/json" and looks for .json
      # templates and layout, so overwrote content-type and hard-coded
      # extension and templating engine.
      render :show, content_type: 'text/html', layout: 'application.html.erb'
    else
      raise_404
    end
  end

  def dashboard
    # rendering a partial in 'listings/index' with formats: [:json],
    # which sets the response to Content-Type="application/json"
    # and looks for .json templates and layout, so overwrote
    # content-type and hard-coded extension and templating engine.
    render 'listings/index', content_type: 'text/html', layout: 'application.html.erb'
  end

  def create
    @user = User.new(params[:user])
    @user.is_real_user = true

    if @user.save
      UserMailer.initial_activation_email(@user).deliver!

      signin_user!(@user)
      redirect_to dashboard_url, notice: "Almost done! Check your inbox for the activation email."
    else
      flash[:alert] = "Something went terribly wrong. Check below."
      render :new
    end
  end

  def activate
    user = User.find_by_activation_token(params[:activation_token])
    (head(404) && return) unless user

    user.activate!
    flash[:notice] = "Activated your account successfully! Enjoy!"

    signin_user!(user)
    redirect_to dashboard_url
  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])

    new_email = params[:user][:new_email]
    if new_email.present? && new_email != @user.email
      changed_email = true
    else
      changed_email = false
      params[:user].delete(:new_email)
    end

    if @user.update_attributes(params[:user])
      if changed_email
        UserMailer.change_email_verification_email(@user).deliver!
      end

      flash[:success] = "Saved changes! #{"Please check your inbox to verify your new email address." if changed_email}"
      redirect_to dashboard_url
    else

      flash.now[:alert] = "Couldn't save changes. Check below."
      render :edit
    end
  end

  def destroy
    @user.deactivate!
    flash[:success] = "Account deactivated.. :("
    redirect_to root_url
  end

end
