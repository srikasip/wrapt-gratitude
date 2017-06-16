module Reports
  class Mvp1bUserSurveySummaryReport
    attr_reader :stats, :surveys
    
    def initialize(surveys)
      @surveys = surveys
      @stats = {}
    end
    
    def questions
      [
        [:age, 'Age'],
        [:gender, 'Gender'],
        [:zip, 'Zipcode']
      ]
    end
        
    def load_stats
      @stats = {}
      
      load_question_stats
    end
    
    def load_question_stats
      questions.each do |question|
        attr = question.first
        @stats[attr] = calculate_question_stats(attr)
      end
    end
    
    def calculate_question_stats(attr)
      question_stats = []
      surveys.group_by do |survey|
        survey[attr].to_s.strip
      end.each do |choice, responses|
        if choice.present?
          question_stats << [choice, responses.count]
        end
      end
      question_stats.sort! do |a, b|
        b.last <=> a.last
      end
      question_stats
    end
  end
end