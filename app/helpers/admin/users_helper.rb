module Admin
  module UsersHelper
    
    def user_sources
      User.sources.reduce(Hash.new) do |result, (source, _also_source)|
        result[source] = source.to_s.humanize
        result
      end
    end 

    def beta_rounds
      User.beta_rounds.reduce(Hash.new) do |result, (beta_round, _also_beta_round)|
        result[beta_round] = beta_round.to_s.humanize
        result
      end
    end

  end  
end

