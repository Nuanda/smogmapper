# temperature = Measurement.create(name: 'temperature', unit: 'C')
# humidity = Measurement.create(name: 'humidity', unit: '%')
# pm = Measurement.create(name: 'pm', unit: 'ug/m3')
temperature = Measurement.find_by_name('temperature')
humidity = Measurement.find_by_name('humidity')
pm = Measurement.find_by_name('pm')

ms = [temperature, humidity, pm]
# sensor = Sensor.create(id: 1000, name: 'My own! My precious!', long: 19.959689, lat: 50.048504, measurements: ms)
sensor = Sensor.find(1000)
(Sensor.all - [sensor]).each{ |s| s.destroy }

puts Sensor.count

fake_sensor_file = File.open('sensorLocation.csv').read
fake_sensor_file.lines.each do |line|
  data = line.split(',')
  sensor = Sensor.create(id: data[0].to_i, name: data[0], long: data[1].to_f, lat: data[2].to_f, measurements: ms)
end

puts Sensor.count
puts Reading.count

11.times.each do |i|
  sensor_value_file = File.open("values#{i + 1}.csv").read
  sensor_value_file.lines.each do |line|
    data = line.split(',')
  	Reading.create(measurement: pm, sensor_id: data[0].to_i, time: Time.now - (i*15).minutes, value: data[1].to_f)
  end
end

puts Reading.count

# 30.times.each do |i|
#   Reading.create(measurement: temperature, sensor: sensor, time: Time.now - (i*15).minutes, value: (rand(60) - 20.0).to_f)
# end
#
# 30.times.each do |i|
#   Reading.create(measurement: humidity, sensor: sensor, time: Time.now - (i*15).minutes, value: rand(100).to_f)
# end
