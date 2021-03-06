FactoryGirl.define do
  factory :list do
    ignore do
      items []
    end

    pref_label "List of things"
    edit_users ["user2"]

    factory :private_list do
      edit_users []
    end

    after(:build) do |list|
      list.members << build(:list_item)
    end
  end

  trait :with_items do
    after(:build) do |list, attrs|
      attrs.items.each do |i|
        list.members << build(:list_item, pref_label: i)
      end
    end
  end

  factory :list_item do
    pref_label "Item 1"
  end
end
