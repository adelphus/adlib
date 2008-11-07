class AdlibUser < ActiveRecord::Base

  validates_presence_of :username
  validates_length_of :username, :maximum => 50, :allow_blank => true
  validates_format_of :username, :with => /^\w*$/
  validates_uniqueness_of :username

  validate :ensure_presence_of_password
  
  def password #:nodoc:
    nil
  end

  # Creates a unique salt and encrypts the provided password. See #authenticated?.
  def password=(password)
    if password.blank?
      self.password_salt = nil
      self.password_hash = nil
    else
      self.password_salt = self.class.make_token
      self.password_hash = self.class.password_digest(password, password_salt)
    end
  end

  # Checks the provided password against the stored encrypted password.
  # If the user cannot be authenticated, an error message is added to base.
  def authenticated?(password)
    if password_hash == self.class.password_digest(password, password_salt)
      return true
    else 
      errors.add_to_base 'Login failed.'
      return false
    end
  end

  class << self #:nodoc: all

    # Makes a SHA1 digest from the provided arguments.
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))      
    end
    
    # Makes a unique random token for use as a password salt.
    def make_token
      secure_digest(Time.now, (1..10).map { rand.to_s })
    end
    
    # Makes a secure digest from the provided password and salt.
    # Uses a site key in addition to the salt and folds the code 10 times.
    def password_digest(password, salt)
      site_key = secure_digest('adelphus_solutions_llc')
      digest = site_key
      10.times do
        digest = secure_digest(digest, salt, password, site_key)
      end
      digest
    end

  end
  
  private

    def ensure_presence_of_password
      errors.add :password, "can't be blank" if password_hash.blank? or password_salt.blank?
    end
  
end
