class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, #:confirmable,
  :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  # Relationships
  has_many :user_questions, dependent: :destroy
  has_many :questions, through: :user_questions
  # Custom validations
  has_attached_file :image, styles: { medium: '410x410>', thumb: '176x176#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # Create the user from the oauth callback
  def self.find_for_oauth(auth, signed_in_resource = nil)
    # Get the identity object from the oauth
    identity = Identity.find_for_oauth(auth)
    # Set the user object
    user = signed_in_resource ? signed_in_resource : identity.user

    # If the user object is nil, process the oauth
    if user.nil?
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email
      # If no user exist with the oauth email, create it
      if user.nil?
        # Create the user object, with the params
        user = User.new(
          name: auth.extra.raw_info.name,
          email: email ? email : "#{(0...8).map { (65 + rand(26)).chr }.join.downcase}-#{auth.uid}@#{auth.provider}.com",
          password: Devise.friendly_token[0,20], # The password is random
          image: URI.parse(auth.info.try(:image).to_s.gsub('http://', 'https://'))
        )
        user.save!
      end
    end
    # Assign the correct user to the identity
    if identity.user != user
      identity.user = user
      identity.save!
    end
    # Return the user object
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

  # Obtain the next training question
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

  # ############################################################################
  # Questions method area
  ##############################################################################

  # Get user questions by category
  def penalty_answers
    @penalty_answers ||= user_questions.by_category('penalty')
  end
  def law_answers
    @law_answers ||= user_questions.by_category('law')
  end
  def sign_answers
    @sign_answers ||= user_questions.by_category('sign')
  end

  # Get corrected answers of questions by category
  def penalty_correct_answers
    @penalty_correct_answers ||= penalty_answers.select{|uq| uq.correct? }
  end
  def law_correct_answers
    @law_correct_answers ||= law_answers.select{|uq| uq.correct? }
  end
  def sign_correct_answers
    @sign_correct_answers ||= sign_answers.select{|uq| uq.correct? }
  end

  # Get success of questions by category
  def penalty_success_rate
    @penalty_success_rate ||= ((penalty_correct_answers.size.to_f / penalty_answers.size) * 100).round(2)
  end
  def law_success_rate
    @law_success_rate ||= ((law_correct_answers.size.to_f / law_answers.size) * 100).round(2)
  end
  def sign_success_rate
    @sign_success_rate ||= ((sign_correct_answers.size.to_f / sign_answers.size) * 100).round(2)
  end

end
