class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :lockable, :timeoutable, :confirmable
  strip_attributes only: [:first_name, :last_name, :email]

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  
  validates_presence_of :first_name, :last_name, :email
  
  def full_name
    [first_name, last_name].join(' ')
  end

  protected
  def password_required?
    return false if new_record?
    super
  end
end
