module ReadingsHelper
  def build_headers
    ["Time", "Sensor id"] + measurements.map(&:name)
  end

  def fetch_batch(offset)
    @readings.offset(offset).limit(10000).pluck(:time, :value, :measurement_id)
  end

  def flush_line(time, buffer)
    [time, @sensor.id] + measurements.map do |m|
      buffer[m.id]
    end
  end

  private

  def measurements
    @measurements ||= @sensor.measurements.sort_by(&:id)
  end
end
