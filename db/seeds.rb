if Rails.env.development?
  temperature = Measurement.create(name: 'temperature', unit: '°C')
  humidity = Measurement.create(name: 'humidity', unit: '%')
  pm = Measurement.create(name: 'pm', unit: 'μg/m³')
  Measurement.create(name: 'pm1', unit: 'μg/m³')
  Measurement.create(name: 'pm2_5', unit: 'μg/m³')
  Measurement.create(name: 'pm10', unit: 'μg/m³')

  ms = [temperature, humidity, pm]

  Sensor.create(id: 1000,
                name: 'My own! My precious!',
                locations: [
                  Location.new(longitude: 19.959689, latitude: 50.048504)
                ],
                measurements: ms)

  fake_sensor_file = File.open('db/seeds/sensorLocation.csv').read
  fake_sensor_file.lines.each do |line|
    data = line.split(',')
    Sensor.create(
      id: data[0].to_i,
      name: data[0],
      measurements: ms
    )
  end

  readings = []
  interval = Rails.application.config_for(:application).
    fetch('measurements', { 'interval' => 15 })['interval']

  11.times.each do |i|
    sensor_value_file = File.open("db/seeds/values#{i + 1}.csv").read
    sensor_value_file.lines.each do |line|
      data = line.split(',')
      sensor_id = data[0].to_i
      time = Time.now - (i * interval).minutes
      readings << Reading.new(measurement: pm, sensor_id: sensor_id, time: time,
                              value: data[1].to_f)
      readings << Reading.new(measurement: temperature, sensor_id: sensor_id, time: time,
                              value: (rand(60) - 20.0).to_f)
      readings << Reading.new(measurement: humidity, sensor_id: sensor_id, time: time,
                              value: rand(100).to_f)
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
