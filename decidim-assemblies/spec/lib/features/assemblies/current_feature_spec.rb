# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    describe CurrentFeature do
      let(:request) { double(params: params, env: env) }
      let(:subject) { described_class.new(manifest) }
      let(:params) { {} }
      let(:manifest) { Decidim.find_feature_manifest("dummy") }

      let(:organization) do
        create(:organization)
      end

      let(:current_assembly) { create(:assembly, organization: organization) }
      let(:other_assembly) { create(:assembly, organization: organization) }

      let(:env) do
        { "decidim.current_organization" => organization }
      end

      context "when the params contain an assembly id" do
        before do
          params["assembly_id"] = current_assembly.id.to_s
        end

        context "when the params don't contain a feature slug" do
          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end

        context "when the params contain a feature slug" do
          before do
            params["feature_slug"] = feature.slug
          end

          context "when the feature doesn't belong to the assembly" do
            let(:feature) { create(:feature, participatory_space: other_assembly) }

            it "matches" do
              expect(subject.matches?(request)).to eq(false)
            end
          end

          context "when the feature belongs to the assembly" do
            let(:feature) { create(:feature, participatory_space: current_assembly) }

            it "matches" do
              expect(subject.matches?(request)).to eq(true)
            end
          end
        end
      end

      context "when the params don't contain an assembly id" do
        it "doesn't match" do
          expect(subject.matches?(request)).to eq(false)
        end
      end

      context "when the params contain a non existing assembly id" do
        before do
          params["assembly_id"] = "99999999"
        end

        context "when there's no feature" do
          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end

        context "when there's feature" do
          before do
            params["feature_slug"] = "my-meetings"
          end

          it "doesn't match" do
            expect(subject.matches?(request)).to eq(false)
          end
        end
      end
    end
  end
end
