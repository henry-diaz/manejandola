class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, #:confirmable,
  :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :user_questions, dependent: :destroy
  has_many :questions, through: :user_questions
  has_attached_file :image, styles: { medium: '410x410>', thumb: '176x176#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # Create the user from the oauth callback
  def self.find_for_oauth(auth, signed_in_resource = nil)

    identity = Identity.find_for_oauth(auth)

    user = signed_in_resource ? signed_in_resource : identity.user

    if user.nil?

    email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
    email = auth.info.email if email_is_verified
    user = User.where(:email => email).first if email

      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          email: email ? email : "#{(0...8).map { (65 + rand(26)).chr }.join.downcase}-#{auth.uid}@#{auth.provider}.com",
          password: Devise.friendly_token[0,20],
          image: URI.parse(auth.info.try(:image).to_s.gsub('http://', 'https://'))
        )
        user.save!
      end
    end

    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end


  # If the user has more than ten questions answered, doesn't need training
  def need_training?
    @need_training ||= (user_questions.count < 10)
  end

  # Obtain the percent training of the user, based on the ten questions
  def percent_training
    @percent_training ||= ((user_questions.count.to_f / 10) * 100).to_i
  end

  def training_question
    # Obtain the categorys of the questions answered
    question_categories = questions.pluck(:category)
    # if the categorys is empty (new user), return a random question
    return Question.random if question_categories.empty?
    h = Hash.new(0)
    # Hashed the values, for count purposes
    question_categories.each { | v | h.store(v, h[v]+1) }
    # We set maximum 4 law questions, and 3 of the others for the training. If the user fulfilled the quota in a category,
    # this method discard a question of that category
    a = Array.new(0)
    a << 'law' if h['law'] < 4
    a << 'penalty' if h['penalty'] < 3
    a << 'sign' if h['sign'] < 3
    # Find the question in the valid category
    Question.where(category: a).random
  end
end
