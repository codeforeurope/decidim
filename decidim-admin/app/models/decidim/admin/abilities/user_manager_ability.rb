# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user with role 'user_manager' in the admin section.
      # Intended to be used with `cancancan`.
      class UserManagerAbility < Decidim::Abilities::UserManagerAbility
        def define_abilities
          super

          can :manage, :managed_users
          cannot [:new, :create], :managed_users if empty_available_authorizations?
          can :impersonate, Decidim::User do |user_to_impersonate|
            user_to_impersonate.managed? && Decidim::ImpersonationLog.active.empty?
          end
          can :promote, Decidim::User do |user_to_promote|
            user_to_promote.managed? && Decidim::ImpersonationLog.active.empty?
          end
        end

        private

        def empty_available_authorizations?
          return unless @context[:current_organization]
          @context[:current_organization].available_authorizations.empty?
        end
      end
    end
  end
end
