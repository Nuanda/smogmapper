FactoryGirl.define do
  factory :measurement do
    name { Faker::Name.name }
    unit { Faker::Lorem.characters(4) }
  end
end
