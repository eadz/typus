def load_data
  @royale_file = File.join(File.dirname(__FILE__), 'royale.yml')
  @royale = File.open(@royale_file) { |file| YAML::load(file) }
end

def timestamp
  Time.now.utc.strftime("%Y%m%d%H%M")
end

