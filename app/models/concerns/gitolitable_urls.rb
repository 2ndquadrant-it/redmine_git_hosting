module GitolitableUrls
  extend ActiveSupport::Concern

  def http_user_login
    User.current.anonymous? ? '' : "#{User.current.login}@"
  end


  def git_access_path
    "#{gitolite_repository_name}.git"
  end


  def http_access_path
    "#{RedmineGitolite::Config.get_setting(:http_server_subdir)}#{redmine_repository_path}.git"
  end


  def ssh_url
    "ssh://#{RedmineGitolite::Config.get_setting(:gitolite_user)}@#{RedmineGitolite::Config.get_setting(:ssh_server_domain)}/#{git_access_path}"
  end


  def git_url
    "git://#{RedmineGitolite::Config.get_setting(:ssh_server_domain)}/#{git_access_path}"
  end


  def http_url
    "http://#{http_user_login}#{RedmineGitolite::Config.get_setting(:http_server_domain)}/#{http_access_path}"
  end


  def https_url
    "https://#{http_user_login}#{RedmineGitolite::Config.get_setting(:https_server_domain)}/#{http_access_path}"
  end


  def allowed_to_commit?
    User.current.allowed_to?(:commit_access, project) ? 'true' : 'false'
  end


  def ssh_access
    { url: ssh_url, commiter: allowed_to_commit? }
  end


  ## Unsecure channels (clear password), commit is disabled
  def http_access
    { url: http_url, commiter: 'false' }
  end


  def https_access
    { url: https_url, commiter: allowed_to_commit? }
  end


  def git_access
    { url: git_url, commiter: 'false' }
  end


  def available_urls
    hash = {}

    if extra[:git_http] == 2
      hash[:https] = https_access
      hash[:http]  = http_access
    end

    hash[:ssh]   = ssh_access if !User.current.anonymous? && User.current.allowed_to?(:create_gitolite_ssh_key, nil, global: true)
    hash[:https] = https_access if extra[:git_http] == 1
    hash[:http]  = http_access if extra[:git_http] == 3
    hash[:git]   = git_access if project.is_public && extra[:git_daemon]

    hash
  end

end