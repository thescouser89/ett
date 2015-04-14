class RelationshipsController < ApplicationController
  # GET /relationships
  # GET /relationships.xml
  def index
    @relationships = Relationship.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @relationships }
    end
  end

  # GET /relationships/1
  # GET /relationships/1.xml
  def show
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @relationship }
    end
  end

  # GET /relationships/new
  # GET /relationships/new.xml
  def new
    @relationship = Relationship.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @relationship }
    end
  end

  # GET /relationships/1/edit
  def edit
    @relationship = Relationship.find(params[:id])
  end

  # POST /relationships
  # POST /relationships.xml
  def create
    if Rails::VERSION::STRING < "4"
      @relationship = Relationship.new(params[:relationship])
    else
      @relationship = Relationship.new(relationship_params)
    end

    respond_to do |format|
      if @relationship.save
        format.html do
          redirect_to(@relationship,
                      :notice => 'Relationship was successfully created.')
        end
        format.xml do
          render :xml => @relationship,
                 :status => :created,
                 :location => @relationship
        end
      else
        format.html { render :action => 'new' }

        format.xml do
          render :xml => @relationship.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /relationships/1
  # PUT /relationships/1.xml
  def update
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      if Rails::VERSION::STRING < "4"
        update_params = @relationship.update_attributes(params[:relationship])
      else
        update_params = @relationship.update_attributes(relationship_params)
      end

      if update_params

        format.html do
          redirect_to(@relationship,
                      :notice => 'Relationship was successfully updated.')
        end

        format.xml { head :ok }
      else
        format.html { render :action => 'edit' }

        format.xml do
          render :xml => @relationship.errors, :status => :unprocessable_entity
        end

      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.xml
  def destroy
    @relationship = Relationship.find(params[:id])
    @relationship.destroy

    respond_to do |format|
      format.html { redirect_to(relationships_url) }
      format.xml { head :ok }
    end
  end

  if Rails::VERSION::STRING > "3"
    private
    def relationship_params
      params.require(:relationship).permit(:id, :from_name, :is_global, :task_id,
                                           :to_name, :name)
    end
  end
end
