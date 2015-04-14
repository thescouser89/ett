class TagsController < ApplicationController
  before_filter :check_task, :only => [:index, :new]
  before_filter :check_can_manage, :only => [:new, :edit]

  def index
    if Rails::VERSION::STRING < "4"
      @tags = Tag.all(:conditions => ['task_id = ?', get_task(params[:task_id]).id])
    else
      @tags = Tag.where('task_id = ?', get_task(params[:task_id]).id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @tags }
    end
  end

  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @tag }
    end
  end

  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @tag }
    end
  end

  # GET /attributes/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  def create
    expire_all_fragments
    if Rails::VERSION::STRING < "4"
      @tag = Tag.new(params[:tags])
    else
      @tag = Tag.new(tags_params)
    end

    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'

        format.html do
          redirect_to(:action => :show,
                      :id => @tag.id,
                      :task_id => escape_url(@tag.task.name))
        end

      else
        format.html { render :action => :new }
      end
    end
  end

  def update
    expire_all_fragments
    @tag = Tag.find(params[:id])

    respond_to do |format|

      if Rails::VERSION::STRING < "4"
        update_result = @tag.update_attributes(params[:tag])
      else
        update_result = @tag.update_attributes(tags_params)
      end

      if update_result
        flash[:notice] = 'Tag was successfully updated.'
        format.html do
          redirect_to(:action => :show,
                      :id => @tag.id,
                      :task_id => @tag.task.name)
        end
      else
        format.html { render :action => :edit }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(attributes_url) }
      format.xml { head :ok }
    end
  end

  if Rails::VERSION::STRING > "3"
    private
    def tags_params
      params.require(:tag).permit(:id, :key, :value, :task_id)
    end
  end
end
