class String

  DB = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV]

  def build_conditions(model)
    conditions = ""
    self.split('&').each do |q|
      the_key = q.split("=").first
      the_value = q.split("=").last

      if the_key == "search"
        search = Array.new
        model.search_fields.each { |s| search << "LOWER(#{s}) LIKE '%#{the_value}%'" }
        conditions << "AND (#{search.join(" OR ")}) "
      end

      model.filters.each do |f|
        filter_type = f[1] if f[0].to_s == the_key.to_s
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
              when "today"
                start_date, end_date = Time.today, Time.today.tomorrow
              when "past_7_days"
                start_date, end_date = Time.today.monday, Time.today.monday.next_week
              when "this_month"
                start_date, end_date = Time.today.last_month, Time.today.tomorrow
              when "this_year"
                start_date, end_date = Time.today.last_year, Time.today.tomorrow
              end
              start_date = start_date.strftime("%Y-%m-%d %H:%M:%S")
              end_date = end_date.strftime("%Y-%m-%d %H:%M:%S")
              conditions << "AND created_at > '#{start_date}' AND created_at < '#{end_date}' "
          when "collection"
            conditions << "AND #{f[0]}_id = #{the_value} "
          end
        end
    end
    return conditions
  end

end