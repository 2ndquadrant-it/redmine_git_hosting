require 'redmine'
require_dependency 'principal'
require_dependency 'user'

require_dependency 'git_hosting'
require_dependency 'git_hosting/patches/repositories_controller_patch'
require_dependency 'git_hosting/patches/repositories_helper_patch'
require_dependency 'git_hosting/patches/git_adapter_patch'

Redmine::Plugin.register :redmine_git_hosting do
	name 'Redmine Git Hosting Plugin'
	author 'Christian Käser, Zsolt Parragi, Yunsang Choi, Joshua Hogendorn, Jan Schulz-Hofen and others'
	description 'Enables Redmine to control hosting of git repositories'
	version '0.1.0'
	settings :default => {
		'gitUser' => 'git',
		'gitServer' => 'localhost',
		'gitoliteIdentityFile' => '/srv/projects/redmine/miner/.ssh/gitolite_admin_id_rsa',
		'gitUserIdentityFile'  => '/srv/projects/redmine/miner/.ssh/git_user_id_rsa',
		'allProjectsUseGit' => 'false',
		
		#these are somewhat deprecated, will be removed in the future in favor of the settings above 
		'gitRepositoryBasePath' => '/srv/projects/git/repositories/',
		'gitoliteUrl' => 'git@localhost:gitolite-admin.git',
		'readOnlyBaseUrls' => "",
		'developerBaseUrls' => ""
		}, 
		:partial => 'redmine_git_hosting'
end

# initialize hook
class GitoliteProjectShowHook < Redmine::Hook::ViewListener
	render_on :view_projects_show_left, :partial => 'redmine_git_hosting'
end

# initialize association from user -> public keys
User.send(:has_many, :gitolite_public_keys, :dependent => :destroy)

#initialize association from repository -> git_repo_hosting_options
Repository.send(:has_one, :git_repo_hosting_options, :dependent => :destroy)

# initialize observer
ActiveRecord::Base.observers = ActiveRecord::Base.observers << GitHostingObserver
