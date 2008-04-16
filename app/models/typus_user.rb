class TypusUser < ActiveRecord::Base

  attr_accessor :password
  attr_protected :hashed_password, :status, :admin

  validates_presence_of :email, :first_name, :last_name
  validates_presence_of :password, :password_confirmation, :if => :new_record?
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_confirmation_of :password, :if => lambda { |person| person.new_record? or not person.password.blank? }
  validates_length_of :password, :within => 6..40, :if => lambda { |person| person.new_record? or not person.password.blank? }

  before_create :generate_token
  before_save :update_password

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

private

  def self.hashed(str)
    SHA1.new(str).to_s
  end

  def self.authenticate(person_info)
    person = find_by_email(person_info[:email])
    if person && person.hashed_password == hashed(person_info[:password]) && person.status == true
      return person
    end
  end

  def update_password
    if not self.password.blank?
      self.hashed_password = self.class.hashed(password)
    end
  end

  def generate_token
    @attributes['token'] = Digest::SHA1.hexdigest((object_id + rand(255)).to_s).slice(0..15)
  end

end