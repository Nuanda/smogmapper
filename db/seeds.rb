if Rails.env.development?
  temperature = Measurement.create(name: 'temperature', unit: '°C')
  humidity = Measurement.create(name: 'humidity', unit: '%')
  pm = Measurement.create(name: 'pm', unit: 'μg/m³')
  pm1 = Measurement.create(name: 'pm1', unit: 'μg/m³')
  pm2_5 = Measurement.create(name: 'pm2_5', unit: 'μg/m³')
  pm10 = Measurement.create(name: 'pm10', unit: 'μg/m³')

  Sensor.create(id: 1000,
                name: 'My own! My precious!',
                locations: [
                  Location.new(longitude: 19.959689, latitude: 50.048504)
                ],
                measurements: [temperature, humidity, pm])

  fake_sensor_file = File.open('db/seeds/sensorLocation.csv').read
  fake_sensor_file.lines.each do |line|
    data = line.split(',')
    Sensor.create(
      id: data[0].to_i,
      name: data[0],
      measurements: case data[0].to_i
                      when 1
                        [temperature, humidity]
                      when 100
                        [temperature, humidity, pm1, pm2_5, pm10]
                      when 200
                        [pm]
                      when 300
                        [pm1, pm2_5]
                      else
                        [temperature, humidity, pm]
                    end
    )
  end

  readings = []
  interval = Rails.application.config_for(:application).
    fetch('measurements', { 'interval' => 15 })['interval']

  4.times.each do |n|
    11.times.each do |i|
      sensor_value_file = File.open("db/seeds/values#{i + 1}.csv").read
      sensor_value_file.lines.each do |line|
        data = line.split(',')
        sensor_id = data[0].to_i
        time = Time.now - ((n * 11 + i) * interval).minutes
        unless sensor_id == 1 || sensor_id == 100 || sensor_id == 300
          readings << Reading.new(measurement: pm, sensor_id: sensor_id, time: time,
                                value: data[1].to_f)
        end
        unless sensor_id == 200 || sensor_id == 300
          readings << Reading.new(measurement: temperature, sensor_id: sensor_id, time: time,
                                  value: (rand(60) - 20.0).to_f)
          readings << Reading.new(measurement: humidity, sensor_id: sensor_id, time: time,
                                  value: rand(100).to_f)
        end
        if sensor_id == 100 || sensor_id == 300
          readings << Reading.new(measurement: pm1, sensor_id: sensor_id, time: time,
                                  value: data[1].to_f * 0.3)
          readings << Reading.new(measurement: pm2_5, sensor_id: sensor_id, time: time,
                                  value: data[1].to_f * 0.7)
          if sensor_id == 100
            readings << Reading.new(measurement: pm10, sensor_id: sensor_id, time: time,
                                    value: data[1].to_f)
          end
        end
      end
    end
  end
  Reading.import(readings)

  fake_sensor_file.lines.each do |line|
    data = line.split(',')
    sensor_id = data[0].to_i
    Location.create(longitude: data[1].to_f, latitude: data[2].to_f, sensor_id: sensor_id)
    if sensor_id == 273
      extra_location = Location.create(longitude: data[1].to_f + 0.01,
                                       latitude: data[2].to_f - 0.01,
                                       sensor_id: sensor_id)
      extra_location.update(registration_time: Time.now - (4 * interval + 1).minutes)
    end
  end
end
