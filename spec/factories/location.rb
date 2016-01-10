FactoryGirl.define do
  factory :location do
    longitude { Faker::Number.decimal(2, 3) }
    latitude { Faker::Number.decimal(2, 3) }
    height { Faker::Number.decimal(2, 3) }
    registration_time { Time.now }

    sensor
  end
end