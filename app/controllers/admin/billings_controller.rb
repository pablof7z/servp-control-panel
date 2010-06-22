class Admin::BillingsController < ApplicationController
	before_filter :load_billing
	
	def view
	end
	
	def update
		@billing.update_attributes(params[:billing])
		@billing.paypal.subscription = params[:billing_paypal][:subscription]
		@billing.paypal.save
		if ! @billing.save
			render :action => 'view'
		else
			flash[:notice] = "Information updated successfully"
			redirect_to :action => 'view', :id => @billing.mask
		end
	end

	private
	
	def load_billing
		@billing = Billing.find_by_mask(params[:id])
		
		@billing.subscriptions # To trigger when no billing

		rescue
			flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
			redirect_to :controller => 'dashboard'
	end
end
