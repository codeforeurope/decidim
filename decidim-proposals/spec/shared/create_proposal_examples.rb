# frozen_string_literal: true

shared_examples "create a proposal" do |with_author|
  let(:feature) { create(:proposal_feature) }
  let(:organization) { feature.organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_feature: feature
    )
  end
  let(:author) { create(:user, organization: organization) } if with_author

  let(:has_address) { false }
  let(:address) { nil }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:attachment_params) { nil }

  describe "call" do
    let(:form_params) do
      {
        title: "A reasonable proposal title",
        body: "A reasonable proposal body",
        address: address,
        has_address: has_address,
        attachment: attachment_params
      }
    end

    let(:command) do
      if with_author
        described_class.new(form, author)
      else
        described_class.new(form)
      end
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create a proposal" do
        expect do
          command.call
        end.not_to change { Decidim::Proposals::Proposal.count }
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new proposal" do
        expect do
          command.call
        end.to change { Decidim::Proposals::Proposal.count }.by(1)
      end

      if with_author
        it "sets the author" do
          command.call
          proposal = Decidim::Proposals::Proposal.last

          expect(proposal.author).to eq(author)
        end
      end

      context "when geocoding is enabled" do
        let(:feature) { create(:proposal_feature, :with_geocoding_enabled) }

        context "when the has address checkbox is checked" do
          let(:has_address) { true }

          context "when the address is present" do
            let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

            before do
              Geocoder::Lookup::Test.add_stub(
                address,
                [{ "latitude" => latitude, "longitude" => longitude }]
              )
            end

            it "sets the latitude and longitude" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal.latitude).to eq(latitude)
              expect(proposal.longitude).to eq(longitude)
            end
          end
        end
      end

      context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
        let(:feature) { create(:proposal_feature, :with_attachments_allowed) }
        let(:attachment_params) do
          {
            title: "My attachment",
            file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
          }
        end

        it "creates an atachment for the proposal" do
          expect do
            command.call
          end.to change { Decidim::Attachment.count }.by(1)
          last_proposal = Decidim::Proposals::Proposal.last
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(last_proposal)
        end

        context "when attachment is left blank" do
          let(:attachment_params) do
            {
              title: ""
            }
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
