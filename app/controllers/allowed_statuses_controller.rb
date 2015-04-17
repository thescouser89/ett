class AllowedStatusesController < ApplicationController
  # GET /allowed_statuses
  # GET /allowed_statuses.xml
  def index
    @allowed_statuses = AllowedStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @allowed_statuses }
    end
  end

  # GET /allowed_statuses/1
  # GET /allowed_statuses/1.xml
  def show
    @allowed_status = AllowedStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @allowed_status }
    end
  end

  # GET /allowed_statuses/new
  # GET /allowed_statuses/new.xml
  def new
    @allowed_status = AllowedStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @allowed_status }
    end
  end

  # GET /allowed_statuses/1/edit
  def edit
    @allowed_status = AllowedStatus.find(params[:id])
  end

  # POST /allowed_statuses
  # POST /allowed_statuses.xml
  def create
    if Rails::VERSION::STRING < "4"
      @allowed_status = AllowedStatus.new(params[:allowed_status])
    else
      @allowed_status = AllowedStatus.new(allowed_statuses_params)
    end

    respond_to do |format|
      if @allowed_status.save

        format.html do
          redirect_to(@allowed_status,
                      :notice => 'AllowedStatus was successfully created.')
        end

        format.xml do
          render :xml => @allowed_status,
                 :status => :created,
                 :location => @allowed_status
        end

      else
        format.html { render :action => 'new' }
        format.xml do
          render :xml => @allowed_status.errors,
                 :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /allowed_statuses/1
  # PUT /allowed_statuses/1.xml
  def update
    @allowed_status = AllowedStatus.find(params[:id])

    respond_to do |format|

      if Rails::VERSION::STRING < "4"
        update_result = @allowed_status.update_attributes(params[:allowed_status])
      else
        update_result = @allowed_status.update_attributes(allowed_statuses_params)
      end
      if update_result
        format.html { redirect_to(@allowed_status, :notice => 'AllowedStatus was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml do
          render :xml => @allowed_status.errors,
                 :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /allowed_statuses/1
  # DELETE /allowed_statuses/1.xml
  def destroy
    @allowed_status = AllowedStatus.find(params[:id])
    @allowed_status.destroy

    respond_to do |format|
      format.html { redirect_to(allowed_statuses_url) }
      format.xml  { head :ok }
    end
  end

  if Rails::VERSION::STRING > "3"
    private
    def allowed_statuses_params
      params.require(:allowed_status).permit(:id, :workflow_id, :status_id,
                                             :next_statuses, :next_status_id)
    end
  end
end
