class TrainingsController < ApplicationController
  before_action :authenticate_user!
  before_action :need_training?
  before_action :valid_training?, only: [:show]

  def index
    # Find a valid question for user and redirect to show
    question = current_user.training_question
    redirect_to training_url(question) and return
  end

  def show
    add_breadcrumb "Dashboard", root_path
    add_breadcrumb "Entrenamiento"
  end

  def answers
    redirect_to root_url, alert: "¡Ups! Lo sentimos, la pregunta que intento contestar no existe." and return unless question
    @answer = current_user.user_questions.where(question_id: question.id).first_or_initialize
    if @answer.new_record?
      @answer.question_id = question.id
      @answer.answer = params[:answer_id]
      @answer.level = question.level
      @answer.save
    end
    add_breadcrumb "Dashboard", root_path
    add_breadcrumb "Entrenamiento"
  end

  def question
    @question ||= Question.find(params[:id])
  end
  helper_method :question

  def need_training?
    redirect_to root_url, notice: '¡Felicidades! Completaste satisfactoriamente el entrenamiento' and return unless current_user.need_training?
  end

  def valid_training?
    redirect_to trainings_url and return if current_user.question_ids.include?(question.id)
  end
end
