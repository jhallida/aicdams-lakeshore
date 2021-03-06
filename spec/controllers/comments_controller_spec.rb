require 'rails_helper'

describe CommentsController do
  include_context "authenticated saml user"

  let(:comment) { Comment.create(content: "Test comment") }
  let(:content) { "updated content" }
  let(:cat1)    { "first category" }

  describe "#update" do
    context "both content and category" do
      before do
        post :update, id: comment, comment: { content: content, category: [cat1] }
        comment.reload
      end
      it "changes the metadata of the comment" do
        expect(response).to be_redirect
        expect(comment.content).to eql content
        expect(comment.category).to include(cat1)
        expect(comment).to be_kind_of(Comment)
      end
    end
    context "removing a category" do
      before { post :update, id: comment, comment: { category: [""] } }
      subject { comment.category }
      it { is_expected.to be_empty }
    end
  end

  describe "#edit" do
    before { get :edit, id: comment }
    subject { response }
    it { is_expected.to be_successful }
  end
end
