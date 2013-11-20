class WorkflowsController < ApplicationController
  # GET /workflows
  # GET /workflows.xml
  def index
    @workflows = Workflow.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @workflows }
    end
  end

  # GET /workflows/1
  # GET /workflows/1.xml
  def show
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @workflow }
    end
  end

  # GET /workflows/new
  # GET /workflows/new.xml
  def new
    @workflow = Workflow.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @workflow }
    end
  end

  # GET /workflows/1/edit
  def edit
    @workflow = Workflow.find(params[:id])
  end

  # POST /workflows
  # POST /workflows.xml
  def create
    @workflow = Workflow.new(params[:workflow])
    # In WildBee we should save workflow and allowedStatus in one transaction.
    # Currently we have to save workflow to get its primary key
    if @workflow.save # just to get primary id.
      @workflow.update_transitions(params[:transitions])

      respond_to do |format|
        format.html { redirect_to(@workflow, :notice => 'Workflow was successfully created.') }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end

  def assign
    @workflow = Workflow.find(params[:id])
  end

  # PUT /workflows/1
  # PUT /workflows/1.xml
  def update
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      if params[:myaction].blank?
        if @workflow.update_attributes(params[:workflow])
          @workflow.update_transitions(params[:transitions])
          format.html { redirect_to(@workflow, :notice => 'Workflow was successfully updated.') }
        else
          format.html { render :action => "edit" }
        end
      else
        if params[:myaction] == 'assign'
          @workflow.assign_to_tasks(params[:tasks])
          format.html { redirect_to(@workflow, :notice => 'Workflow has been assigned to tasks.') }
        end
      end
    end
  end

  # DELETE /workflows/1
  # DELETE /workflows/1.xml
  def destroy
    @workflow = Workflow.find(params[:id])
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to(workflows_url) }
      format.xml { head :ok }
    end
  end

  protected


end
