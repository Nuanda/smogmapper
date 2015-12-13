temperature = Measurement.create(name: 'temperature', unit: 'C')
humidity = Measurement.create(name: 'humidity', unit: '%')
pm = Measurement.create(name: 'pm', unit: 'ug/m3')
ms = [temperature, humidity, pm]
# sensor = Sensor.create(id: 1000, name: 'My own! My precious!', long: 50.048504, lat: 19.959689, measurements: ms)

fake_sensor_file = File.open('sensorLocation.csv').read
fake_sensor_file.lines[1,10].each do |line|
  data = line.split(',')
  sensor = Sensor.create(id: data[0].to_i, name: data[0], long: data[1].to_f, lat: data[2].to_f, measurements: ms)

  30.times.each do |i|
    Reading.create(measurement: pm, sensor: sensor, time: Time.now - (i*15).minutes, value: rand(500).to_f)
  end
end

# 30.times.each do |i|
#   Reading.create(measurement: temperature, sensor: sensor, time: Time.now - (i*15).minutes, value: (rand(60) - 20.0).to_f)
# end
#
# 30.times.each do |i|
#   Reading.create(measurement: humidity, sensor: sensor, time: Time.now - (i*15).minutes, value: rand(100).to_f)
# end
