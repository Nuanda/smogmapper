FactoryGirl.define do
  factory :sensor do
    name { Faker::Name.name }
    long { Faker::Number.decimal(2, 3) }
    lat { Faker::Number.decimal(2, 3) }
  end
end
