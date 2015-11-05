require 'rails_helper'

describe GenericFilesController do
  routes { Sufia::Engine.routes }
  let(:user) { FactoryGirl.find_or_create(:jill) }
  before do
    allow(controller).to receive(:has_access?).and_return(true)
    sign_in user
    allow_any_instance_of(User).to receive(:groups).and_return([])
    allow_any_instance_of(GenericFile).to receive(:characterize)
  end

  describe "#create" do
    let(:mock) { GenericFile.new }
    let(:batch) { Batch.create }
    let(:batch_id) { batch.id }
    let(:file) { fixture_file_upload('/sun.png') }

    before { allow(GenericFile).to receive(:new).and_return(mock) }

    context "without an asset type" do
      before { xhr :post, :create, files: [file], Filename: 'The sun', batch_id: batch_id, terms_of_service: '1' }
      it "should return an error" do
        expect(response).to be_redirect
        expect(flash[:error]).to eql "You must provide an asset type"
      end
    end

    context "with an incorrect asset type" do
      before { xhr :post, :create, files: [file], Filename: 'The sun', batch_id: batch_id, terms_of_service: '1', asset_type: "asdf" }
      it "should return an error" do
        expect(response).to be_redirect
        expect(flash[:error]).to eql "Asset type must be either still_image or text"
      end
    end

    context "with a StillImage type" do
      let(:generic_file) { Batch.find(response.request.params["batch_id"]).generic_files.first }
      it "sets the asset type to StillImage" do
        file = fixture_file_upload('/sun.png')
        xhr :post, :create, files: [file], Filename: 'The sun', batch_id: batch_id, terms_of_service: '1', asset_type: 'still_image'
        expect(response).to be_success
        expect(generic_file.type).to include AICType.StillImage
      end
    end

    context "with a Text type" do
      let(:generic_file) { Batch.find(response.request.params["batch_id"]).generic_files.first }
      it "sets the asset type to Text" do
        file = fixture_file_upload('/text.txt')
        xhr :post, :create, files: [file], Filename: 'Sample text file', batch_id: batch_id, terms_of_service: '1', asset_type: 'text'
        expect(response).to be_success
        expect(generic_file.type).to include AICType.Text
      end
    end    

    context "with an incorrect StillImage mime type" do
      it "returns an error" do
        file = fixture_file_upload('/text.txt')
        xhr :post, :create, files: [file], Filename: 'An incorrect image file', batch_id: batch_id, terms_of_service: '1', asset_type: 'still_image'
        expect(response).to be_redirect
        expect(flash[:error]).to eql "Submitted file does not have a mime type for a still image"
      end
    end

    context "with an incorrect Text mime type" do
      it "returns an error" do
        file = fixture_file_upload('/fake_photoshop.psd')
        xhr :post, :create, files: [file], Filename: 'An incorrect text file', batch_id: batch_id, terms_of_service: '1', asset_type: 'text'
        expect(response).to be_redirect
        expect(flash[:error]).to eql "Submitted file does not have a mime type for a text file"
      end
    end

    context "with an unknown mime type" do
      it "returns an error" do
        file = fixture_file_upload('/fake_file.xzy')
        xhr :post, :create, files: [file], Filename: 'File with an unknown mime type', batch_id: batch_id, terms_of_service: '1', asset_type: 'text'
        expect(response).to be_redirect
        expect(flash[:error]).to eql "Submitted file is an unknown mime type"
      end
    end
  end
end
