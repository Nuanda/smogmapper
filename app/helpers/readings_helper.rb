module ReadingsHelper
  def build_time_series
    @headers = "Sensor id","Measurement name"
    @data = {}
    @sensor.measurements.each do |measurement|
      @data[measurement.id] = [@sensor.id, measurement.name]
    end

    if @readings.present?
      last_time = @readings[0].time
      buffer = {}
      @readings.each_with_index do |reading, i|
        if reading.time > last_time
          flush_buffer(last_time, buffer)
          last_time = reading.time
          buffer = {}
        end
        buffer[reading.measurement_id] = reading.value
      end
      flush_buffer(last_time, buffer)
    end
    [@headers, @data]
  end

  private

  def flush_buffer(header_time, buffer)
    @headers << header_time
    @sensor.measurements.each do |measurement|
      @data[measurement.id] << buffer[measurement.id]
    end
  end
end
