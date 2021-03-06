# == Schema Information
#
# Table name: tasks
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  description             :text
#  can_show                :string(255)
#  total_manual_track_time :integer
#  candidate_tag           :string(255)
#  target_release          :string(255)
#  tag_version             :string(255)
#  milestone               :string(255)
#  advisory                :string(255)
#  workflow_id             :integer
#  prod                    :string(255)
#  active                  :string(255)
#  repository              :string(255)
#  frozen_state            :string(255)
#  allow_non_existent_pkgs :boolean
#  allow_non_shipped_pkgs  :boolean
#  previous_version_tag    :string(255)
#  build_branch            :string(255)
#

class Task < ActiveRecord::Base
#  acts_as_tree
  validates_presence_of :name
  validates_uniqueness_of :name

  default_value_for :can_show, 'Yes'
  default_value_for :total_manual_track_time, 0

  has_many :tags, :dependent => :destroy
  has_many :packages, :dependent => :destroy
  has_many :statuses, :dependent => :destroy

  has_many :os_advisory_tags, :dependent => :destroy

  has_many :component_views
  has_many :components, :through => :component_views

  has_many :task_group_to_tasks
  has_many :task_groups, :through => :task_group_to_tasks


  has_one :setting, :class_name => 'Setting', :foreign_key => 'task_id'

  belongs_to :workflow
  belongs_to :coordinator, :class_name => 'User', :foreign_key => 'coordinator_id'

  acts_as_textiled :description

  LINK = {:tag => 0, :package => 1}

  def self.tasks_to_ids(tasks)
    task_ids = []
    tasks.each do |task|
      task_ids << task.id
    end
    task_ids
  end

  def frozen_state?
    self.frozen_state == "1"
  end

  def self.from_task_ids(task_ids)
    tasks = []
    task_ids.each do |task_id|
      task = Task.find(task_id.to_i)
      tasks << task
    end
    tasks
  end

  def unclosed_pr_pkgs
    self.packages.select do |package|
      !package.github_pr.blank? &&
      (package.github_pr_closed.nil? || package.github_pr_closed == false)
    end
  end

  def self.all_that_have_package_with_name(name)
    Task.all(:conditions => ['id in (select task_id from packages where name = ?)', name])
  end

  def use_bz_integration?
    if setting.blank?
      false
    else
      setting.use_bz_integration?
    end
  end

  def use_jira_integration?
    if setting.blank?
      false
    else
      setting.use_jira_integration?
    end
  end

  def use_mead_integration?
    if setting.blank?
      false
    else
      setting.use_mead_integration?
    end
  end

  def readonly?
    !ReadonlyTask.find_by_task_id(id).blank?
  end

  def self.readonly?(task)
    !ReadonlyTask.find_by_task_id(task.id).blank?
  end

  def active_packages # find the packages of the task which the workload time need to be tracked.
    # If the package status's 'is_track_time' field is not 'No', then the workload of this package needs to be tracked.
    # So we will consider this package as active.
    # For example if the package is in 'Deleted' status, and because 'Deleted' status's 'is_track_time' is set to 'No',
    # so we think the packages marked in 'Delete' status is inactive.
    Package.all(:conditions => ["task_id = ? and status_id in (select id from statuses where is_track_time != 'No') or status_id is null", id])
  end

  def active?
    self.active == "1"
  end

  def sorted_os_advisory_tags
    OsAdvisoryTag.all(:conditions => ['task_id = ?', self.id], :order => :priority)
  end

  def distros
    tags = self.sorted_os_advisory_tags
    distros = []
    tags.each do |tag|
      distros << tag.os_arch
    end
    distros
  end

  def primary_os_advisory_tag
    primary = sorted_os_advisory_tags[0]
    if primary.blank?
      OsAdvisoryTag.new
    else
      primary
    end
  end

  def has_pkg_with_optional_errata?
    Package.find(:all,
                 :conditions => ['task_id = ? and errata > ?', self.id, '']).count != 0
  end

  def get_dist_git_branch

    branch = ''

    branch = self.os_advisory_tags.first.candidate_tag unless self.os_advisory_tags.blank?

    # override the branch string if the field build_branch is specified
    branch = self.build_branch unless self.build_branch.blank?

    branch
  end
end
