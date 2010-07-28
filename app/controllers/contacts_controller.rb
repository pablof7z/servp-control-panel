class ContactsController < ApplicationController
  before_filter :load_contact_detail, :except => [ :index, :new, :create ]

  def index
  end

  def new
    @contact_detail = ContactDetail.new
    @contact_detail.user = @user
  end

  def create
    @contact_detail = ContactDetail.new(params[:contact_details])
    @contact_detail.user = @user
    if @contact_detail.update_attributes(params[:contact_details])
      flash[:notice] = "Contact details created successfully."
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @contact_detail.update_attributes(params[:contact_details])
      NewsfeedItem.new(:user_id => @user.id, :text => "has updated <a href=\"#{CP_PREFIX}/contacts/edit/#{@contact_detail.mask}\">some #{@contact_detail.mechanism} information</a>").save
      flash[:notice] = "Contact details updated successfully."
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def delete
    if @contact_detail.destroy
      flash[:notice] = "Contact details removed successfully."
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end

  private

  def load_contact_detail
    @contact_detail = ContactDetail.find_by_mask(params[:id])
    @contact_detail.allowed_for current_user
  rescue
    flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
    redirect_to :action => 'index'
  end
end
