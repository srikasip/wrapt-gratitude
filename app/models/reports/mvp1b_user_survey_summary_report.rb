module Reports
  class Mvp1bUserSurveySummaryReport
    attr_reader :stats, :surveys
    
    def initialize(surveys)
      @surveys = surveys.preload(:user)
      @stats = {}
    end
    
    def questions
      [
        [:age, 'What age group are you in?'],
        [:gender, 'What is your gender?'],
        [:zip, 'What is your zip code?'],
        [:response_confidence, 'How confident do you feel about your responses to the quiz?'],
        [:recommendation_confidence, 'How confident do you feel that the software made good gift recommendations?'],
        [:recommendation_comment, 'Either way, why?'],
        [:would_use_again, 'How likely would you be to use this site again on your own?'],
        [:would_tell_friend, 'How likely would you be to use this site for yourself to create a wish list to share with friends & family, or purchase items??'],
        [:other_services, 'Would you use Wrapt to notify you of her upcoming gift occasions such as her birthday, anniversary or other important dates? Once you take her quiz and get recommendations, we send you reminders or gifts that match her based on your initial quiz - would this interest you?'],
        [:mailing_address, 'We would like to show our appreciation for your time with a small gift from Wrapt--please tell us your mailing address if you are interested.']
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
      total_response_count = 0
      surveys.group_by do |survey|
        survey[attr].to_s.strip
      end.each do |choice, responses|
        if choice.present?
          total_response_count += responses.count
          question_stats << {
            choice: choice,
            count: responses.count,
            pct: 0.0,
            users: responses.map{|r| r.user.email}
          }
        end
      end
      question_stats.each do |qstat|
        qstat[:pct] = 100.0 * qstat[:count] / total_response_count
      end
      question_stats.sort! do |a, b|
        b[:count] <=> a[:count]
      end
      question_stats
    end
  end
end