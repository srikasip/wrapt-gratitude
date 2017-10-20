module UsaState
  PATH = File.join(Rails.root, 'db', 'states.yml').to_s

  def self.abbreviations
    @abbreviations ||= YAML.load_file(PATH).keys
  end
end
