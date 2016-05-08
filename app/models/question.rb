class Question < ActiveRecord::Base
  searchkick

  has_attached_file :image, styles: { medium: '410x410>', thumb: '176x176#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  scope :random,  -> { order('RANDOM()').limit(1).first }

  CATEGORY = {
    'penalty' => 'Multas',
    'law' => 'Ley de tránsito',
    'sign' => 'Señales'
  }

  def category_s
    CATEGORY[category]
  end

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
