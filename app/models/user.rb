class User < ActiveRecord::Base

  attr_accessor :password
  attr_protected :hashed_password

  validates_presence_of :first_name, :last_name
  validates_presence_of :password, :password_confirmation, :if => :new_record?

  validates_uniqueness_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_confirmation_of :password, :if => lambda { |person| person.new_record? or not person.password.blank? }
  validates_length_of :password, :within => 6..40, :if => lambda { |person| person.new_record? or not person.password.blank? }

  before_create :generate_token
  before_save :update_password

  has_many :ads

  def to_param
    "#{id}-#{full_name.to_url}"
  end

  def full_name
    "#{first_name} #{last_name}"
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
