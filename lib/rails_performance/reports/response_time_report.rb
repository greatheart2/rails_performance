module RailsPerformance
  module Reports
    class ResponseTimeReport < BaseReport
      def set_defaults
        @group ||= :datetime
      end

      def data
        all     = {}
        stop    = RailsPerformance::Reports::BaseReport::time_in_app_time_zone(Time.at(60 * (Time.now.to_i / 60)))
        offset  = RailsPerformance::Reports::BaseReport::time_in_app_time_zone(Time.now).utc_offset
        current = stop - RailsPerformance.duration
        @data   = []

        # puts "current: #{current}"
        # puts "stop: #{stop}"

        # read current values
        db.group_by(group).each do |(k, v)|
          durations = v.collect{|e| e["duration"]}.compact
          next if durations.empty?
          all[k] = durations.sum.to_f / durations.count
        end

        # add blank columns
        while current <= stop
          views = all[current.strftime(RailsPerformance::FORMAT)] || 0
          # time = RailsPerformance::Reports::BaseReport::time_in_app_time_zone(current)
          @data << [(current.to_i + offset) * 1000, views.round(2)]
          current += 1.minute
        end

        # sort by time
        @data.sort!
      end
    end
  end
end
