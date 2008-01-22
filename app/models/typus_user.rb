class TypusUser < ActiveRecord::Base

  validates_presence_of :email

  def self.authenticate(user)
    user = find_by_email(user[:name])
    # if person && person.hashed_password == hashed(person_info[:password])
    if user && user.password == user[:password]
      return user
    end
  end

  # This will get the list of the available models for this user
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

end