require 'rails_helper'

describe Resource do
  describe "RDF type" do
    subject { described_class.new.type }
    it { is_expected.to eql([AICType.Resource]) }
  end

  describe "terms" do
    subject { described_class.new }
    ResourceTerms.all.each do |term|
      it { is_expected.to respond_to(term) }
    end
  end

  describe "nested resources" do
    let(:resource) { described_class.new }

    context "with other assets" do
      let(:asset) { create(:asset) }

      before do
        ResourceTerms.related_asset_ids.map { |rel| resource.send(rel.to_s + "=", [asset.id]) }
        resource.save
        resource.reload
      end

      specify "are types of GenericFile objects" do
        expect(resource.documents).to include(GenericFile)
        expect(resource.representations).to include(GenericFile)
        expect(resource.preferred_representations).to include(GenericFile)
      end
    end

    context "with a MetadataSet" do
      let(:metadata) do
        MetadataSet.create.tap(&:save)
      end

      before do
        resource.described_by = [metadata]
        resource.save
        resource.reload
      end

      subject { resource.described_by }
      it { is_expected.to include(MetadataSet) }
    end
  end

  describe "cardinality" do
    [:batch_uid, :resource_created, :dept_created, :resource_updated, :status, :pref_label, :uid, :icon].each do |term|
      it "limits #{term} to a single value" do
        subject.send(term.to_s + "=", "foo")
        expect(subject.send(term.to_s)).to eql "foo"
      end
    end
  end

  describe "#resource_created" do
    context "with a bad date" do
      let(:bad_resource) { described_class.create(resource_created: "bad date") }
      subject { ActiveFedora::Base.load_instance_from_solr(bad_resource.id) }
      its(:resource_created) { is_expected.to eq("bad date is not a valid date") }
    end
  end

  describe "::find_by_label" do
    let!(:list1) { create(:list, pref_label: "Foo List") }
    let!(:list2) { create(:list, pref_label: "A Foo List") }
    subject { List.find_by_label(label) }
    context "with an exact search" do
      let(:label) { "Foo List" }
      its(:pref_label) { is_expected.to eq(label) }
    end
    context "with a fuzzy search" do
      let(:label) { "List" }
      it { is_expected.to be_nil }
    end
  end
end
