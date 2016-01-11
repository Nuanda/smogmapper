FactoryGirl.define do
  factory :location do
    longitude { Faker::Number.between(-180, 180) }
    latitude { Faker::Number.between(-90, 90) }
    height { Faker::Number.between(0, 20) }

    sensor
  end
end