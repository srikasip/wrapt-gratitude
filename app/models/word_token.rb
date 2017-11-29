class WordToken
  def self.sample
    @dictionary ||= File.readlines(File.join(Rails.root, 'db', 'words.txt')).map(&:strip)

    @dictionary.sample
  end
end
