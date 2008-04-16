class TypusUser < ActiveRecord::Base

  attr_accessor :password

  validates_presence_of :email, :first_name, :last_name
  validates_presence_of :password, :password_confirmation, :if => :new_record?
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_confirmation_of :password, :if => lambda { |person| person.new_record? or not person.password.blank? }
  validates_length_of :password, :within => 6..40, :if => lambda { |person| person.new_record? or not person.password.blank? }

  before_create :generate_token
  before_save :encrypt_password

  # This will get the list of the available models for this user
  # Currently is not working
  def models
    available_models = Typus::Configuration.config
    models_for_this_user = []
    available_models.to_a.each do |m|
      models_for_this_user << m[0].constantize if m[1]['roles'].include? self.role
    end
    return models_for_this_user
  rescue
    []
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def reset_password(password, host)
    TypusMailer.deliver_password(self, password, host)
    self.update_attributes(:password => password, :password_confirmation => password)
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    user && user.authenticated?(password) ? user : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

protected

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{full_name}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def encrypt(password)
    Digest::SHA1.hexdigest("--#{salt}--#{password}")
  end

  def generate_token
    @attributes['token'] = Digest::SHA1.hexdigest((object_id + rand(255)).to_s).slice(0..15)
  end

end