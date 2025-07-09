require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require "dagwood"

module Rdt
  SCHEMA = "rdt"

  def self.settings
    @settings ||= begin
      rdt_path = Rails.root.join("config", "rdt.yml").to_s
      dbt_path = Rails.root.join("config", "dbt.yml").to_s
      path = File.exist?(rdt_path) ? rdt_path : dbt_path
      if File.exist?(path)
        YAML.safe_load(ERB.new(File.read(path)).result, aliases: true)
      else
        {}
      end
    end
  end

  def self.run(...)
    Runner.run(...)
  end

  def self.test(...)
    Runner.test(...)
  end
end

Dbt = Rdt
