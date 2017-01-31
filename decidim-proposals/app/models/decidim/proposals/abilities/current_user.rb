# frozen_string_literal: true
module Decidim
  module Proposals
    module Abilities
      # Defines the abilities related to proposals for a logged in user.
      # Intended to be used with `cancancan`.
      class CurrentUser
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :vote, Proposal do |_proposal|
            voting_enabled? && remaining_votes.positive?
          end

          can :unvote, Proposal do |_proposal|
            voting_enabled? && vote_limit_enabled?
          end

          can :create, Proposal if current_settings.try(:creation_enabled?)
        end

        private

        def vote_limit_enabled?
          return unless feature_settings
          feature_settings.vote_limit.present? && feature_settings.vote_limit.positive?
        end

        def remaining_votes
          return 1 unless vote_limit_enabled?

          proposals = Proposal.where(feature: context.fetch(:current_feature))
          votes_count = ProposalVote.where(author: user, proposal: proposals).size
          feature_settings.vote_limit - votes_count
        end

        def voting_enabled?
          return unless current_settings
          current_settings.votes_enabled? && !current_settings.votes_blocked?
        end

        def current_settings
          context.fetch(:current_settings, nil)
        end

        def feature_settings
          context.fetch(:feature_settings, nil)
        end
      end
    end
  end
end