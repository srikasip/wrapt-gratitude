class GifteeInvitationsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.giftee_invitations_mailer.review_gift_selections_invitation.subject
  #
  def review_gift_selections_invitation profile
    @profile = profile
    mail to: @profile.email, subject: 'Someone was shopping for you on Wrapt'
  end
end
