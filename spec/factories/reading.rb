FactoryGirl.define do
  factory :reading do
    time { Time.now }
    value { Faker::Number.decimal(2, 3) }

    measurement
    sensor
  end
end
