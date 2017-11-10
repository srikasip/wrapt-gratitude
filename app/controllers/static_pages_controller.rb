class StaticPagesController < ApplicationController
  include FeatureFlagsHelper

  helper SurveyQuestionResponsesHelper
  helper FeatureFlagsHelper
  helper CarouselHelper

  before_action :load_survey, only: [:science_of_gifting, :rewrapt, :about]

  def science_of_gifting
    @boxes = [
      {id: 'shoe', title: "The Shoe Doesn't Fit.", content: "We have a hard time putting ourselves in other people's shoes", citations: [1, 4]},
      {id: 'ball', title: "You're not a crystal ball", content: "We are bad at predicting what gifts people will appreciate the most", citations: [5]},
      {id: 'bag', title: "Doesn't everyone like what i like?", content: "We tend to think our inner circle has the same interests that we do", citations: [1]}
    ]
    @tagline = {content: "We buy gifts because we care. But we often worry we will choose the wrong gift, disappointing the very person we were hoping to delight.", citations: [1, 2, 3]}
    @content = [
      {container: 'sg-content', content: ['So how do we turn gift giving around from stressful to successful? First, choose gifts that the other person would really want to receive. That means matching the gift to the recipient as best as possible.'], citations: [], header: {text: "And the wrong gift can tear us apart instead of bringing us together.", citations: [6]}},
      {container: 'sg-quote', content: 'The most important thing in the exchanging of gifts is it shows that you really know the person well, and you really care about them.', credit: '- Dr. Ryan Howell, PhD, San Francisco State University'},
      {container: 'sg-content', content: ['We designed Wrapt to make a match between your gift recipient and the right gift. Because she is one of a kind, out Wrapt quiz asks you a few questions &mdash; about her personality, passions and purpose, that helps us to identify the best collection for her. Then, we share that collection of matched gifts with you &mdash; gifts that speak to her style, her interests, personality type and what she cares about.'], citations: [], header: {text:'The right gift for your recipient', citations: []}},
      {container: 'sg-content', content: ["On top of this, Wrapt gifts are artisanal &mdash; of the hand-made, fair trade, and sustainable variety, makeing more recipients feel special than mass-made items.", "These gifts also support artisan communities in the US and around the globe, offering Maker stories of positive social change that make our gifts extra special."], citations: [[7]], header: {text:'Gifts that support artisanal communities', citations: []}}
    ]
    @references = [
      {text: 'Flynn, F.J. and G.S. Adams, Money can’t buy love: Asymmetric beliefs about gift price and feelings of appreciation. Journal of Experimental Social Psychology, 2009. 45(2): p. 404-409. [pdf]', short_text: 'Flynn, F.J. and G.S. Adams, (2009),', link: 'http://francisflynn.org/wp-content/uploads/2010/03/Money-cant-buy-love.pdf'},
      {text: 'Wooten, D.B., Qualitative steps toward an expanded model of anxiety in gift-giving. Journal of Consumer Research, 2000. 27(1): p. 84-95. [pdf]', short_text: 'Wooten, D.B., (2000),', link: 'https://www.researchgate.net/profile/David_Wooten2/publication/24099051_Qualitative_Steps_toward_an_Expanded_Model_of_Anxiety_in_Gift-Giving/links/55d784f708ae9d65948d93a0.pdf'},
      {text: 'Kleber, S., Can AI Finally Help Humans Choose the Right Gift? Huge 2016; Available from: http://www.hugeinc.com/ideas/perspective/can-ai-finally-help-humans-choose-the-right-gift.', short_text: 'Kleber, S., (2016),', link: 'http://www.hugeinc.com/ideas/perspective/can-ai-finally-help-humans-choose-the-right-gift'},
      {text: 'Ross, L., D. Greene, and P. House, The “false consensus effect”: An egocentric bias in social perception and attribution processes. Journal of experimental social psychology, 1977. 13(3): p. 279-301. [pdf]', short_text: 'Ross, L., D. Greene, and P. House, (1977),', link: 'http://www.kafaak.com/wp-content/uploads/2014/06/Ross-et-al-The-false-consensus-effect-an-egocentric-bias-in-social-perception-and-attribution-processes.pdf'},
      {text: 'Ward, M.K. and S.M. Broniarczyk, It’s not me, it’s you: How gift giving creates giver identity threat as a function of social closeness. Journal of Consumer Research, 2011. 38(1): p. 164-181. [pdf]', short_text: 'Ward, M.K. and S.M. Broniarczyk, (2011),', link: 'http://www.ejcr.org/Curations/Curations-PDFs/Curations4/Ward_Broniarczyk.pdf'},
      {text: 'Ruth, J.A., C.C. Otnes, and F.F. Brunel, Gift receipt and the reformulation of interpersonal relationships. Journal of Consumer Research, 1999. 25(4): p. 385-402. [pdf]', short_text: 'Ruth, J.A., C.C. Otnes, and F.F. Brunel, (1999),', link: 'https://www.researchgate.net/profile/Julie_Ruth/publication/24099017_Gift_Receipt_and_the_Reformulation_of_Interpersonal_Relationships/links/02e7e51e934068390c000000.pdf'},
      {text: "Fuchs, C., M. Schreier, and S.M. van Osselaer, The Handmade Effect: What's Love Got to Do with It? Journal of marketing, 2015. 79(2): p. 98-110. [pdf]", short_text: 'Fuchs, C., M. Schreier, and S.M. van Osselaer, (2015)', link: 'https://www.researchgate.net/profile/Stijn_Van_Osselaer/publication/273529358_The_Handmade_Effect_What%27s_Love_Got_to_Do_with_It/links/55cb517208aeb975674c5f58/The-Handmade-Effect-Whats-Love-Got-to-Do-with-It.pdf'}
    ]
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def page_404
    respond_to do |f|
      f.html
      f.xml { render(xml: {status: 404, message: 'Page not found'}) }
      f.json { render(json: {status: 404, message: 'Page not found'}) }
      f.png { send_file('public/email-signature-images/logo.png') }
    end
  end

  def login_required?
    false
  end

  private

  def load_survey
    @survey ||= Survey.published.first

    first_question = if @survey.sections.any?
      @survey.sections.first.questions.first
    else
      @survey.questions.first
    end
    @question_response = SurveyQuestionResponse.new survey_question: first_question
  end
end
