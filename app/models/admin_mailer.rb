class AdminMailer < ActionMailer::Base

  def password(person, password)
    @from = 'ob-art produccions <do-not-reply@ob-art.com>'
    @subject = "[ob-art produccions] Admin Password Reset"
    @sent_on = Time.now
    @recipients = person.email
    body(:person => person, :password => password)
    @bcc = "francesc.esplugas@gmail.com"
  end

end
