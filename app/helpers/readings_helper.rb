module ReadingsHelper
  def build_time_series
    @headers = ["Time", "Sensor id"] + measurements.map(&:name)
    @data = []

    if @readings.present?
      last_time = @readings[0].time
      buffer = {}
      @readings.each_with_index do |reading, i|
        if reading.time.to_i > last_time.to_i
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

  def flush_buffer(time, buffer)
    @data << [time, @sensor.id] + measurements.map do |m|
                                    buffer[m.id]
                                  end
  end

  def measurements
    @measurements ||= @sensor.measurements.sort_by(&:id)
  end
end
