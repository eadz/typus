class AdminMailer < ActionMailer::Base

  def password(person, password)
    @from = 'The Typus Robot <do-not-reply@intraducibles.net>'
    @subject = "[TYPUS] Admin Password Reset"
    @sent_on = Time.now
    @recipients = person.email
    body(:person => person, :password => password)
  end

end
