class Identity < ActiveRecord::Base
  # Relationships
  belongs_to :user
  # Custom validations
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  # Find a object with the uid and the provider, if not exist, we create it
  def self.find_for_oauth(auth)
    find_or_create_by(uid: auth.uid, provider: auth.provider)
  end
end
