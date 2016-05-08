class PracticesController < ApplicationController
  before_action :authenticate_user!

  def index
    # Find a valid question for user and redirect to show
    if params[:category]
      question = Question.where(category: params[:category]).random
      redirect_to practice_url(question, category: params[:category]) and return
    else
      question = Question.random
      redirect_to practice_url(question) and return
    end
  end

  def show
    add_breadcrumb "Dashboard", root_path
    add_breadcrumb "Practicar", practices_url
    if params[:category]
      add_breadcrumb Question::CATEGORY[params[:category].to_s]
    end
  end

  def respond
    redirect_to root_url, alert: "¡Ups! Lo sentimos, la pregunta que intento contestar no existe." and return unless question
    @answer = current_user.user_questions.new
    @answer.question_id = question.id
    @answer.answer = params[:answer_id]
    @answer.level = question.level
    @answer.save
    redirect_to answer_practice_url(question, params[:answer_id], category: params[:category]) and return
  end

  def answers
    redirect_to root_url, alert: "¡Ups! Lo sentimos, la pregunta que intento contestar no existe." and return unless question
    @answer = current_user.user_questions.limit(1).order(id: :desc).where(question_id: question.id).first
    add_breadcrumb "Dashboard", root_path
    add_breadcrumb "Practicar", practices_url
    if params[:category]
      add_breadcrumb Question::CATEGORY[params[:category].to_s]
    end
  end

  def question
    @question ||= Question.find(params[:id])
  end
  helper_method :question

end
