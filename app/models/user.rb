class User < ActiveRecord::Base

  validates_uniqueness_of :email

  validates_presence_of :first_name, :last_name, :email
  validates_presence_of :password, :password_confirmation, :if => :new_record?

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create

  validates_confirmation_of :password, :message => "Passwords don't match"

  before_create :encrypt_password
  before_update :encrypt_password_unless_empty_or_unchanged
  before_create :generate_access_key

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.sha1(phrase)
    Digest::SHA1.hexdigest("--typus--#{phrase}--")
  end

  def self.authenticate(email, password, is_admin)
    find_by_email_and_password_and_is_admin(email, sha1(password), is_admin)
  end

  def after_initialize
    @confirm_password = true
  end

  def confirm_password?
    @confirm_password
  end

  def generate_access_key
    @attributes['access_key'] = Digest::SHA1.hexdigest((object_id + rand(255)).to_s)
  end

  # def self.trash(id)
  #  @person = Person.find(id)
  #  @person.deleted_at = Time.now
  #  @person.deleted = true
  #  @person.blocked = true
  #  @person.save
  # end

  # def self.recover(id)
  #  @person = Person.find(id)
  #  @person.deleted = false
  #  @person.save
  # end

private

  def validate_length_of_password?
    new_record? or not password.to_s.empty?
  end

  def encrypt_password
    self.password = self.class.sha1(password)
  end

  def encrypt_password_unless_empty_or_unchanged
    user = self.class.find(self.id)
    case self.password
      when ''
        self.password = user.password
      else
        encrypt_password
      end
  end
  
end
