class TypusMailer < ActionMailer::Base

  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def password(user, password, host)
    @subject    = "[#{Typus::Configuration.options[:app_name]}] Your new password"
    @body       = { :user => user, :password => password, :host => host }
    @recipients = user.email
    typus_user = TypusUser.find(:first)
    @from       = "\"#{typus_user.full_name}\" <#{typus_user.email}>"
    @sent_on    = Time.now
    @headers    = {}
  end

end