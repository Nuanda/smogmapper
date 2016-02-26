ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

pm10 = Measurement.where(name: ['pm10'])
pms = Measurement.where(name: ['pm2_5', 'pm10'])

Sensor.create(name: 'Aleja Krasińskiego',
              sensor_type: 'reference',
              locations: [
                Location.new(longitude: 19.926189, latitude: 50.057678)
              ],
              measurements: pms)

Sensor.create(name: 'Nowa Huta',
              sensor_type: 'reference',
              locations: [
                Location.new(longitude: 20.053492, latitude: 50.069308)
              ],
              measurements: pms)

Sensor.create(name: 'Kurdwanów',
              sensor_type: 'reference',
              locations: [
                Location.new(longitude: 19.949189, latitude: 50.010575)
              ],
              measurements: pms)

Sensor.create(name: 'Ulica Dietla',
              sensor_type: 'reference',
              locations: [
                Location.new(longitude: 19.946008, latitude: 50.057447)
              ],
              measurements: pm10)

Sensor.create(name: 'Osiedle Piastów',
              sensor_type: 'reference',
              locations: [
                Location.new(longitude: 20.018317, latitude: 50.099361)
              ],
              measurements: pm10)

Sensor.create(name: 'Ulica Złoty Róg',
              sensor_type: 'reference',
              locations: [
                Location.new(longitude: 19.895358, latitude: 50.081197)
              ],
              measurements: pm10)
