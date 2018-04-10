class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i  # thanks, Rubular
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # gives us the Bcrypt digest for a given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # gives us a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Boolean for whether the given token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")  # made generic
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # forget a user during logout
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # activates an account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # sets the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  
  # sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  private
  
  # convert all chars in email to lowercase
  def downcase_email
    email.downcase!  #automatically assigns this to self.email
  end
  
  # create and assign the activation token and digest to newly created user
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  
end
