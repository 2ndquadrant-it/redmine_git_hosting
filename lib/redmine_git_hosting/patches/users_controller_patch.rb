require_dependency 'users_controller'

module RedmineGitHosting
  module Patches
    module UsersControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :edit,   :git_hosting
          alias_method_chain :update, :git_hosting

          helper :gitolite_public_keys
        end
      end


      module InstanceMethods


        def edit_with_git_hosting(&block)
          # Set public key values for view
          set_public_key_values

          # Previous routine
          edit_without_git_hosting(&block)
        end


        def update_with_git_hosting(&block)
          # Previous routine
          update_without_git_hosting(&block)
          UpdateProjects.new(@user.gitolite_projects.map{ |p| p.id }, update_options).call if @user.status_has_changed?
        end


        private


          # Add in values for viewing public keys:
          def set_public_key_values
            @gitolite_user_keys   = @user.gitolite_public_keys.user_key.order('title ASC, created_at ASC')
            @gitolite_deploy_keys = @user.gitolite_public_keys.deploy_key.order('title ASC, created_at ASC')
            @gitolite_public_key  = GitolitePublicKey.new
          end


          def update_options
            { message: "User status has changed, update projects" }
          end

      end

    end
  end
end

unless UsersController.included_modules.include?(RedmineGitHosting::Patches::UsersControllerPatch)
  UsersController.send(:include, RedmineGitHosting::Patches::UsersControllerPatch)
end
