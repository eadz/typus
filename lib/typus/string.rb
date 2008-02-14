class String

  DB = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV]

  def build_conditions(model)
    conditions = ""
    self.split('&').each do |q|
      the_key, the_value = q.split("=").first, q.split("=").last
      if the_key == "search"
        search = Array.new
        model.typus_defaults_for('search').each { |s| search << "LOWER(#{s}) LIKE '%#{the_value}%'" }
        conditions << "AND (#{search.join(" OR ")}) "
      end
      model.model_fields.each do |f|
        filter_type = f[1] if f[0] == the_key
        case filter_type
        when "boolean"
          if %w(sqlite3 sqlite).include? DB['adapter']
            conditions << "AND #{f[0]} = '#{the_value[0..0]}' "
          else
            status = (the_value == 'true') ? 1 : 0
            conditions << "AND #{f[0]} = '#{status}' "
          end
        when "datetime"
          case the_value
          when 'today':         start_date, end_date = Time.today, Time.today.tomorrow
          when 'past_7_days':   start_date, end_date = 6.days.ago.midnight, Time.today.tomorrow
          when 'this_month':    start_date, end_date = Time.today.last_month, Time.today.tomorrow
          when 'this_year':     start_date, end_date = Time.today.last_year, Time.today.tomorrow
          end
          start_date, end_date = start_date.to_s(:db), end_date.to_s(:db)
          conditions << "AND created_at > '#{start_date}' AND created_at < '#{end_date}' "
        when "collection"
          conditions << "AND #{f[0]} = #{the_value} "
        end
      end
    end
    return conditions
  end

end
