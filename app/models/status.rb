# == Schema Information
#
# Table name: statuses
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  task_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  global          :string(255)
#  can_select      :string(255)
#  can_show        :string(255)
#  code            :string(255)
#  style           :text
#  is_track_time   :string(255)
#  is_finish_state :string(255)
#  can_change_code :string(255)
#

class Status < ActiveRecord::Base
  belongs_to :task
#  validates_presence_of :task_id
  validates_presence_of :name
#  validates_uniqueness_of :code, :allow_nil => true

  default_value_for :global, 'N'
  default_value_for :can_select, 'Yes'
  default_value_for :can_show, 'Yes'
  default_value_for :can_change_code, 'Yes'
  default_value_for :is_track_time, 'Yes'
  default_value_for :style, ''
  default_value_for :is_finish_state, 'No'

  CODES = {:open => 'open', :needupgrade => 'needupgrade', :inprogress => 'inprogress', :finished => 'finished', :needfix => 'needfix', :blocked => 'blocked'}

  def is_global?
    self.global == 'Y'
  end

  def is_time_tracked?
    is_track_time?
  end

  def is_track_time?
    if is_track_time.blank?
      return false
    end
    is_track_time == 'Yes'
  end

  def can_show?
    self.can_show == 'Yes'
  end

  def self.deleted_status
    Status.find_by_code('deleted')
  end

  def self.find_all_can_select_only_in_global_scope
    Status.find(:all,
                :conditions => ["(global='Y') AND can_select='Yes'"],
                :order => 'lower(name)')
  end

  def self.find_all_can_show_by_task_id_in_global_scope(task_id)
    Status.find(:all,
                :conditions => ["(task_id = ? OR global='Y') AND can_show='Yes'", task_id],
                :order => 'lower(name)')
  end

  def self.ids_can_show_by_task_name_in_global_scope(task_name)
    statuses = Status.find_all_can_show_by_task_id_in_global_scope(Task.find_by_name(task_name).id)
    __str = ''
    statuses.each do |status|
      __str << "#{status.id} ,"
    end
    __str[0..__str.size - 2]
  end

  def self.find_all_can_select_by_task_id_in_global_scope(task_id)
    Status.find(:all,
                :conditions => ["(task_id = ? or global='Y') AND can_select='Yes'", task_id],
                :order => 'lower(name)')
  end

  def self.find_all_can_select_by_task_id(task_id)
    Status.find(:all,
                :conditions => ["(task_id = ?) AND can_select='Yes'", task_id],
                :order => 'lower(name)')
  end

  def self.find_in_global_scope(status_name, task_name)
    global_status = Status.find(:first,
                                :conditions => ["name = ? and global='Y'", status_name])
    if global_status.nil?
      return Status.find_by_name_and_task_id(status_name,
                                             Task.find_by_name(task_name).id)
    else
      return global_status
    end
  end

  def can_change_code?
    can_change_code == 'Yes'
  end

  def self.blank_status
    blank_status = Status.new
    blank_status.id = ''
    blank_status.name = '-'
    blank_status
  end

  def self.statuses_for_selection(package)
    statuses = []
    statuses << Status.blank_status

    if package.task.blank? || package.task.workflow.blank?
      statuses << Status.find_all_can_show_by_task_id_in_global_scope(package.task.id)
    else
      # get current status of package
      current_status = package.status

      # if current_status is blank, get start status
      if current_status.blank?
        statuses += package.task.workflow.start_status_workflows.map {|wk| wk.status}
      else # or get next statuses of current status defined in workflow
        # include current status by default
        statuses << current_status
        statuses << package.task.workflow.next_statuses_of(current_status)
      end
    end
    statuses.flatten.uniq.reject {|status| status.nil?}
  end

  def status_in_finished
    self.code == Status::CODES[:finished]
  end

  def status_in_progress
    self.code == Status::CODES[:inprogress]
  end

  protected

  def validate
    status = Status.find_by_name_and_task_id(self.name.strip, self.task_id)
    if status == nil
      status = Status.find(:first,
                           :conditions => ["global='Y' and name = ?", self.name.strip])
    end

    if status && status.id != self.id
      errors.add(:name, ' - Status name cannot be duplicate under one task!')
    end
  end


end
