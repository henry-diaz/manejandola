class UserQuestion < ActiveRecord::Base
  # Relationships
  belongs_to :user
  belongs_to :question

  # Scopes
  scope :by_category, ->(c) { joins(:question).includes(:question).where(questions: { category: c }) }

  # Get the correct answer of the original question
  def correct_answer
    @correct_answer ||= question.correct
  end

  # Return true if the answer selected is the same from the method correct_answer
  def correct?
    @correct ||= (answer == correct_answer)
  end
end
