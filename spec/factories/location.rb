FactoryGirl.define do
  factory :location do
    latitude { Faker::Number.between(-90,90) }
    longitude { Faker::Number.between(-180,180) }
    sensor
  end
end
