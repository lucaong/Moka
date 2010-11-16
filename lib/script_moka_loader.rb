module Moka
  module ScriptMokaLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) + RbConfig::CONFIG["EXEEXT"]
    SCRIPT_MOKA = File.join('script', 'moka')

    def self.exec_script_moka!
      exec RUBY, SCRIPT_MOKA, *ARGV if in_moka_application?
    end

    def self.in_moka_application?
      File.exists?("manifest.yml")
    end
  end
end