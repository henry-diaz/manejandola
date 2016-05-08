class UserQuestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  def correct_answer
    @correct_answer ||= question.correct
  end

  def correct?
    @correct ||= (answer == correct_answer)
  end
end
