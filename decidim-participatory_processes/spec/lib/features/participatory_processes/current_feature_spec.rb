# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe CurrentFeature do
      let(:request) { double(params: params, env: env) }
      let(:subject) { described_class.new(manifest) }
      let(:params) { {} }
      let(:manifest) { Decidim.find_feature_manifest("dummy") }

      let(:organization) do
        create(:organization)
      end

      let(:participatory_processes) do
        create_list(:participatory_process, 2, organization: organization)
      end

      let(:current_participatory_process) { participatory_processes.first }

      let(:env) do
        { "decidim.current_organization" => organization }
      end

      context "when the params contain a participatory_process id" do
        before do
          params["participatory_process_id"] = current_participatory_process.id.to_s
        end

        context "when the params don't contain a feature id" do
          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end

        context "when the params contain a feature id" do
          before do
            params["feature_slug"] = feature.slug
          end

          context "when the feature doesn't belong to the participatory process" do
            let(:feature) { create(:feature) }

            it "matches" do
              expect(subject.matches?(request)).to eq(false)
            end
          end

          context "when the feature belongs to the participatory process" do
            let(:feature) { create(:feature, participatory_space: current_participatory_process) }

            it "matches" do
              expect(subject.matches?(request)).to eq(true)
            end
          end
        end
      end

      context "when the params don't contain a participatory process id" do
        it "doesn't match" do
          expect(subject.matches?(request)).to eq(false)
        end
      end

      context "when the params contain a non existing participatory process id" do
        before do
          params["participatory_process_id"] = "99999999"
        end

        context "when there's no feature" do
          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end

        context "when there's feature" do
          before do
            params["feature_id"] = "1"
          end

          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end
      end
    end
  end
end
