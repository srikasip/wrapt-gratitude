module Admin
  module UsersHelper
    
    def user_sources
      User::SOURCES.reduce(Hash.new) do |result, source|
        result[source] = source.to_s.humanize
        result
      end
    end 

    def beta_rounds
      User::BETA_ROUNDS.reduce(Hash.new) do |result, beta_round|
        result[beta_round] = beta_round.to_s.humanize
        result
      end
    end

  end  
end

