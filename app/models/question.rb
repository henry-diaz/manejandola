class Question < ActiveRecord::Base
  # For search using elastic_search
  searchkick

  # Custom validations
  has_attached_file :image, styles: { medium: '410x410>', thumb: '176x176#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # Scopes
  scope :random,  -> { order('RANDOM()').limit(1).first } # Get a random question
  scope :for_user, ->(u) { where(category: u.weak_category) }

  # Constants
  CATEGORY = {
    'penalty' => 'Multas',
    'law' => 'Ley de tránsito',
    'sign' => 'Señales'
  }

  # Return category pretty string
  def category_s
    CATEGORY[category]
  end

  # Return a bootstrap glyphicon icon, depends of the category of a question
  def glyphicon
    case category
    when 'penalty'
      return 'glyphicon-usd'
    when 'law'
      return 'glyphicon-road'
    else
      return 'glyphicon-warning-sign'
    end
  end
end
