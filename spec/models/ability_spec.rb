require 'rails_helper'
require 'cancan/matchers'

describe Sufia::Ability do
  let(:user1) { create(:user1) }
  let(:user2) { create(:user2) }
  let(:admin) { create(:admin) }
  let(:file)  { create(:asset) }

  context "with department visibility" do
    context "registered users cannot read a GenericFile" do
      subject { Ability.new(user2) }
      it { is_expected.not_to be_able_to(:read, file) }
    end
  end

  describe "List resources" do
    let(:list) { create(:list) }
    context "with a who does not have edit access" do
      subject { Ability.new(user1) }
      it { is_expected.not_to be_able_to(:edit, list) }
    end
    context "with a who does have edit access" do
      subject { Ability.new(user2) }
      it { is_expected.to be_able_to(:edit, list) }
    end
    context "with an admin user" do
      subject { Ability.new(admin) }
      it { is_expected.to be_able_to(:edit, list) }
    end
  end
end
