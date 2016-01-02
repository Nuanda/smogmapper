if Rails.env.development?
  temperature = Measurement.create(name: 'temperature', unit: '°C')
  humidity = Measurement.create(name: 'humidity', unit: '%')
  pm = Measurement.create(name: 'pm', unit: 'μg/m³')

  ms = [temperature, humidity, pm]

  Sensor.create(id: 1000, name: 'My own! My precious!', long: 19.959689, lat: 50.048504, measurements: ms)

  fake_sensor_file = File.open('db/seeds/sensorLocation.csv').read
  fake_sensor_file.lines.each do |line|
    data = line.split(',')
    Sensor.create(id: data[0].to_i, name: data[0], long: data[1].to_f, lat: data[2].to_f, measurements: ms)
  end

  11.times.each do |i|
    sensor_value_file = File.open("db/seeds/values#{i + 1}.csv").read
    sensor_value_file.lines.each do |line|
      data = line.split(',')
      Reading.create(measurement: pm, sensor_id: data[0].to_i, time: Time.now - (i*15).minutes, value: data[1].to_f)
      Reading.create(measurement: temperature, sensor_id: data[0].to_i, time: Time.now - (i*15).minutes, value: (rand(60) - 20.0).to_f)
      Reading.create(measurement: humidity, sensor_id: data[0].to_i, time: Time.now - (i*15).minutes, value: rand(100).to_f)
    end
  end
end
